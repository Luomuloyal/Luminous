import 'package:luminous/api/my_medicine_api.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/viewmodels/medicine.dart';
import 'package:luminous/viewmodels/my_medicine.dart';
import 'package:sqflite/sqflite.dart';

/// 保存“我的药品”后的结果对象。
class SaveMedicineResult {
  /// 是否为本次新增。
  final bool added;

  /// 当前数据是否已经同步到远端。
  final bool remoteSynced;

  /// 创建一个保存结果对象。
  const SaveMedicineResult({required this.added, required this.remoteSynced});
}

/// “我的药品”仓库。
///
/// 负责统一管理：
/// - 本地 SQLite 缓存；
/// - 远端“我的药品”增删查同步；
/// - 登录用户与游客数据隔离。
class MyMedicineRepository {
  /// 私有构造函数。
  MyMedicineRepository._();

  /// 全局单例入口。
  static final MyMedicineRepository instance = MyMedicineRepository._();

  /// 规范化用户 id。
  String normalizeUserId(String? userId) => (userId ?? '').trim();

  /// 生成带用户作用域的 identityKey。
  String buildScopedIdentityKey({
    String? userId,
    required String drugCode,
    required String approvalNo,
    required String productName,
  }) {
    final uid = normalizeUserId(userId);
    final rawKey = drugCode.trim().isNotEmpty
        ? 'drugCode:${drugCode.trim()}'
        : approvalNo.trim().isNotEmpty
        ? 'approvalNo:${approvalNo.trim()}'
        : 'name:${productName.trim()}';
    if (uid.isEmpty) {
      return 'guest|$rawKey';
    }
    return 'user:$uid|$rawKey';
  }

  /// 根据药品对象生成带作用域的 identityKey。
  String buildScopedIdentityKeyFromMedicine(
    MedicineItem item, {
    String? userId,
  }) {
    return buildScopedIdentityKey(
      userId: userId,
      drugCode: item.drugCode,
      approvalNo: item.approvalNo,
      productName: item.productName,
    );
  }

  /// 读取当前作用域下的本地“我的药品”列表。
  Future<List<Map<String, dynamic>>> loadLocalRows({String? userId}) async {
    final db = await AppDatabase.instance.database;
    return db.query(
      'my_medicines',
      where: 'userId = ?',
      whereArgs: [normalizeUserId(userId)],
      orderBy: 'createdAt DESC',
    );
  }

  /// 读取当前作用域下已经存在的 identityKey 集合。
  Future<Set<String>> loadIdentityKeys({String? userId}) async {
    final rows = await loadLocalRows(userId: userId);
    return rows
        .map((row) => row['identityKey']?.toString() ?? '')
        .where((key) => key.isNotEmpty)
        .toSet();
  }

  /// 新增一条“我的药品”记录。
  ///
  /// - 游客：仅落本地；
  /// - 登录用户：先落本地，再尽量同步到云端。
  Future<SaveMedicineResult> addMedicine({
    required MedicineItem item,
    required String source,
    String? userId,
  }) async {
    final uid = normalizeUserId(userId);
    final identityKey = buildScopedIdentityKeyFromMedicine(item, userId: uid);
    final db = await AppDatabase.instance.database;

    final existing = await db.query(
      'my_medicines',
      columns: ['remoteId'],
      where: 'identityKey = ?',
      whereArgs: [identityKey],
      limit: 1,
    );
    if (existing.isNotEmpty) {
      return SaveMedicineResult(
        added: false,
        remoteSynced: _isRemoteSynced(existing.first['remoteId']),
      );
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert('my_medicines', {
      'identityKey': identityKey,
      'userId': uid,
      'remoteId': '',
      'drugCode': item.drugCode,
      'approvalNo': item.approvalNo,
      'productName': item.productName,
      'dosageForm': item.dosageForm,
      'specification': item.specification,
      'manufacturer': item.manufacturer.isNotEmpty
          ? item.manufacturer
          : item.marketingAuthorizationHolder,
      'source': source,
      'createdAt': now,
    });

    var remoteSynced = uid.isEmpty;
    if (uid.isNotEmpty) {
      try {
        final response = await MyMedicineApi.upsert(
          userId: uid,
          identityKey: identityKey,
          drugCode: item.drugCode,
          approvalNo: item.approvalNo,
          productName: item.productName,
          dosageForm: item.dosageForm,
          specification: item.specification,
          manufacturer: item.manufacturer.isNotEmpty
              ? item.manufacturer
              : item.marketingAuthorizationHolder,
          source: source,
        );
        await _upsertLocalRecord(response.result);
        remoteSynced = true;
      } catch (_) {
        remoteSynced = false;
      }
    }

    return SaveMedicineResult(added: true, remoteSynced: remoteSynced);
  }

  /// 同步当前登录用户的远端“我的药品”到本地。
  ///
  /// 同步顺序：
  /// 1. 先尝试把本地未同步的记录补推到远端；
  /// 2. 再拉远端完整列表；
  /// 3. 用远端结果覆盖当前用户本地缓存，并保留仍未同步成功的记录。
  Future<void> syncRemote(String userId) async {
    final uid = normalizeUserId(userId);
    if (uid.isEmpty) {
      return;
    }

    await _migrateGuestToUser(uid);
    await _pushPendingLocal(uid);
    final pendingRows = await _loadPendingRows(uid);
    final response = await MyMedicineApi.list(userId: uid);
    await _replaceLocalForUser(
      uid,
      response.result.items,
      pendingRows: pendingRows,
    );
  }

  /// 删除一条“我的药品”记录。
  ///
  /// 如果存在远端 id，会先删远端，再删本地。
  Future<void> deleteMedicine(
    Map<String, dynamic> row, {
    String? userId,
  }) async {
    final uid = normalizeUserId(userId);
    final db = await AppDatabase.instance.database;
    final localId = row['id'];
    final remoteId = (row['remoteId'] ?? '').toString().trim();
    final identityKey = (row['identityKey'] ?? '').toString().trim();

    if (uid.isNotEmpty && (remoteId.isNotEmpty || identityKey.isNotEmpty)) {
      await MyMedicineApi.delete(
        userId: uid,
        id: remoteId,
        identityKey: identityKey,
      );
    }

    if (localId is int) {
      await db.delete('my_medicines', where: 'id = ?', whereArgs: [localId]);
      return;
    }

    if (identityKey.isNotEmpty) {
      await db.delete(
        'my_medicines',
        where: 'identityKey = ?',
        whereArgs: [identityKey],
      );
    }
  }

  /// 把本地 pending 记录补推到远端。
  Future<void> _pushPendingLocal(String userId) async {
    final pendingRows = await _loadPendingRows(userId);
    for (final row in pendingRows) {
      try {
        final response = await MyMedicineApi.upsert(
          userId: userId,
          identityKey: (row['identityKey'] ?? '').toString(),
          drugCode: (row['drugCode'] ?? '').toString(),
          approvalNo: (row['approvalNo'] ?? '').toString(),
          productName: (row['productName'] ?? '').toString(),
          dosageForm: (row['dosageForm'] ?? '').toString(),
          specification: (row['specification'] ?? '').toString(),
          manufacturer: (row['manufacturer'] ?? '').toString(),
          source: (row['source'] ?? 'search').toString(),
        );
        await _upsertLocalRecord(response.result);
      } catch (_) {
        // 保留本地 pending 状态，等待下一次同步。
      }
    }
  }

  /// 将游客模式下添加的药品迁移到当前登录用户作用域。
  ///
  /// 迁移后的记录会变成：
  /// - userId = 当前用户 id；
  /// - identityKey 从 `guest|xxx` 转为 `user:{id}|xxx`；
  /// - remoteId 清空，作为待同步记录交由 `_pushPendingLocal` 补推到云端。
  Future<void> _migrateGuestToUser(String userId) async {
    final db = await AppDatabase.instance.database;
    final guestRows = await db.query(
      'my_medicines',
      where: 'userId = ?',
      whereArgs: const [''],
      orderBy: 'createdAt DESC',
    );
    if (guestRows.isEmpty) {
      return;
    }

    await db.transaction((txn) async {
      for (final row in guestRows) {
        final localId = row['id'];
        final oldKey = (row['identityKey'] ?? '').toString().trim();
        if (oldKey.isEmpty) {
          if (localId is int) {
            await txn.delete(
              'my_medicines',
              where: 'id = ?',
              whereArgs: [localId],
            );
          }
          continue;
        }

        final pipeIndex = oldKey.indexOf('|');
        final rawKey = pipeIndex >= 0
            ? oldKey.substring(pipeIndex + 1)
            : oldKey;
        final newKey = 'user:$userId|$rawKey';

        await txn.insert('my_medicines', {
          'identityKey': newKey,
          'userId': userId,
          'remoteId': '',
          'drugCode': (row['drugCode'] ?? '').toString(),
          'approvalNo': (row['approvalNo'] ?? '').toString(),
          'productName': (row['productName'] ?? '').toString(),
          'dosageForm': (row['dosageForm'] ?? '').toString(),
          'specification': (row['specification'] ?? '').toString(),
          'manufacturer': (row['manufacturer'] ?? '').toString(),
          'source': (row['source'] ?? '').toString(),
          'createdAt': row['createdAt'] is int
              ? row['createdAt'] as int
              : int.tryParse((row['createdAt'] ?? '').toString()) ?? 0,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        if (localId is int) {
          await txn.delete(
            'my_medicines',
            where: 'id = ?',
            whereArgs: [localId],
          );
        }
      }
    });
  }

  /// 读取当前用户还未同步到远端的记录。
  Future<List<Map<String, dynamic>>> _loadPendingRows(String userId) async {
    final db = await AppDatabase.instance.database;
    return db.query(
      'my_medicines',
      where: "userId = ? AND (remoteId IS NULL OR remoteId = '')",
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  /// 用远端结果替换当前用户本地缓存，并保留仍未同步的本地记录。
  Future<void> _replaceLocalForUser(
    String userId,
    List<MyMedicineRecord> remoteItems, {
    required List<Map<String, dynamic>> pendingRows,
  }) async {
    final db = await AppDatabase.instance.database;
    final mergedRows = <Map<String, dynamic>>[];
    final seen = <String>{};

    for (final item in remoteItems) {
      final row = item.toLocalMap();
      final identityKey = (row['identityKey'] ?? '').toString();
      if (identityKey.isEmpty || !seen.add(identityKey)) {
        continue;
      }
      mergedRows.add(row);
    }

    for (final row in pendingRows) {
      final identityKey = (row['identityKey'] ?? '').toString();
      if (identityKey.isEmpty || !seen.add(identityKey)) {
        continue;
      }
      mergedRows.add({
        'identityKey': identityKey,
        'userId': userId,
        'remoteId': '',
        'drugCode': (row['drugCode'] ?? '').toString(),
        'approvalNo': (row['approvalNo'] ?? '').toString(),
        'productName': (row['productName'] ?? '').toString(),
        'dosageForm': (row['dosageForm'] ?? '').toString(),
        'specification': (row['specification'] ?? '').toString(),
        'manufacturer': (row['manufacturer'] ?? '').toString(),
        'source': (row['source'] ?? '').toString(),
        'createdAt': row['createdAt'] is int
            ? row['createdAt'] as int
            : int.tryParse((row['createdAt'] ?? '').toString()) ?? 0,
      });
    }

    await db.transaction((txn) async {
      await txn.delete(
        'my_medicines',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      for (final row in mergedRows) {
        await txn.insert(
          'my_medicines',
          row,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 把远端同步成功后的记录写回本地。
  Future<void> _upsertLocalRecord(MyMedicineRecord record) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'my_medicines',
      record.toLocalMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 当前记录是否已经有远端 id。
  bool _isRemoteSynced(dynamic remoteId) {
    return (remoteId ?? '').toString().trim().isNotEmpty;
  }
}

/// 对外暴露的全局“我的药品”仓库实例。
final myMedicineRepository = MyMedicineRepository.instance;

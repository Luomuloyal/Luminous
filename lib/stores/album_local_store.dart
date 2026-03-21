import 'package:luminous/stores/app_database.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:sqflite/sqflite.dart';

/// 相册本地缓存的统一读写入口。
class AlbumLocalStore {
  AlbumLocalStore._();

  static final AlbumLocalStore instance = AlbumLocalStore._();

  /// 读取相册条目，并按 remoteId 折叠历史重复记录。
  Future<List<AlbumEntry>> loadEntries() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        'album_items',
        orderBy: 'COALESCE(takenAt, createdAt) DESC, createdAt DESC, id DESC',
      );
      return _collapseRows(rows);
    } catch (_) {
      return const [];
    }
  }

  /// 保存一条新的本地识别记录。
  Future<void> saveScanRecord({
    String? remoteId,
    String? drugCode,
    String? approvalNo,
    String? productName,
    required String thumbBase64,
    required String imageBase64,
    required int takenAt,
    String source = 'scan',
  }) async {
    final db = await AppDatabase.instance.database;
    await db.insert('album_items', {
      'remoteId': _trimOrNull(remoteId),
      'identityKey': _buildIdentityKey(
        drugCode: drugCode,
        approvalNo: approvalNo,
        productName: productName,
      ),
      'drugCode': _trimOrEmpty(drugCode),
      'approvalNo': _trimOrEmpty(approvalNo),
      'productName': _trimOrEmpty(productName),
      'filePath': '',
      'thumbBase64': thumbBase64.trim(),
      'imageBase64': imageBase64.trim(),
      'takenAt': takenAt,
      'source': source.trim().isEmpty ? 'scan' : source.trim(),
      'createdAt': takenAt,
    });
  }

  /// 把远端识别记录回写到本地，并保留已有原图。
  Future<void> upsertRemoteRecords(List<ScanRecordItem> items) async {
    final remoteItems = [
      for (final item in items)
        if (item.id.trim().isNotEmpty) item,
    ];
    if (remoteItems.isEmpty) {
      return;
    }

    final db = await AppDatabase.instance.database;
    await db.transaction((txn) async {
      final existingByRemoteId = await _loadExistingRemoteRows(
        txn,
        remoteItems,
      );
      for (final item in remoteItems) {
        final remoteId = item.id.trim();
        final duplicates = existingByRemoteId[remoteId] ?? const [];
        final preservedImageBase64 = _firstNonEmpty(
          duplicates.map((row) => (row['imageBase64'] ?? '').toString()),
        );
        final preservedCreatedAt = _resolveCreatedAt(
          duplicates,
          fallback: item.takenAt,
        );
        final keepId = duplicates.isNotEmpty
            ? (duplicates.first['id'] as int?) ?? 0
            : 0;

        final values = <String, Object?>{
          'remoteId': remoteId,
          'identityKey': _buildIdentityKey(
            drugCode: item.drugCode,
            approvalNo: item.approvalNo,
            productName: item.productName,
          ),
          'drugCode': item.drugCode.trim(),
          'approvalNo': item.approvalNo.trim(),
          'productName': item.productName.trim(),
          'filePath': '',
          'thumbBase64': item.thumbBase64.trim(),
          'imageBase64': preservedImageBase64,
          'takenAt': item.takenAt,
          'source': 'scan',
          'createdAt': preservedCreatedAt,
        };

        if (keepId > 0) {
          await txn.update(
            'album_items',
            values,
            where: 'id = ?',
            whereArgs: [keepId],
          );
          final duplicateIds = [
            for (final row in duplicates.skip(1))
              if ((row['id'] as int?) != null) row['id'] as int,
          ];
          if (duplicateIds.isNotEmpty) {
            final placeholders = List.filled(
              duplicateIds.length,
              '?',
            ).join(',');
            await txn.delete(
              'album_items',
              where: 'id IN ($placeholders)',
              whereArgs: duplicateIds,
            );
          }
        } else {
          await txn.insert('album_items', values);
        }
      }
    });
  }

  Future<Map<String, List<Map<String, Object?>>>> _loadExistingRemoteRows(
    Transaction txn,
    List<ScanRecordItem> items,
  ) async {
    final remoteIds = items
        .map((item) => item.id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();
    if (remoteIds.isEmpty) {
      return const {};
    }

    final placeholders = List.filled(remoteIds.length, '?').join(',');
    final rows = await txn.query(
      'album_items',
      columns: ['id', 'remoteId', 'imageBase64', 'createdAt'],
      where: 'remoteId IN ($placeholders)',
      whereArgs: remoteIds,
      orderBy: 'createdAt ASC, id ASC',
    );

    final result = <String, List<Map<String, Object?>>>{};
    for (final row in rows) {
      final remoteId = (row['remoteId'] ?? '').toString().trim();
      if (remoteId.isEmpty) {
        continue;
      }
      result.putIfAbsent(remoteId, () => <Map<String, Object?>>[]).add(row);
    }
    return result;
  }

  List<AlbumEntry> _collapseRows(List<Map<String, Object?>> rows) {
    final singles = <AlbumEntry>[];
    final grouped = <String, List<Map<String, Object?>>>{};

    for (final row in rows) {
      final remoteId = (row['remoteId'] ?? '').toString().trim();
      if (remoteId.isEmpty) {
        singles.add(AlbumEntry.fromLocalRow(row));
        continue;
      }
      grouped.putIfAbsent(remoteId, () => <Map<String, Object?>>[]).add(row);
    }

    final merged = [
      ...singles,
      for (final rows in grouped.values) _mergeDuplicateRows(rows),
    ];
    merged.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return merged;
  }

  AlbumEntry _mergeDuplicateRows(List<Map<String, Object?>> rows) {
    final sorted = [...rows]
      ..sort((a, b) {
        final aTakenAt =
            (a['takenAt'] as int?) ?? (a['createdAt'] as int?) ?? 0;
        final bTakenAt =
            (b['takenAt'] as int?) ?? (b['createdAt'] as int?) ?? 0;
        return bTakenAt.compareTo(aTakenAt);
      });
    final newest = Map<String, Object?>.from(sorted.first);
    newest['imageBase64'] = _firstNonEmpty(
      sorted.map((row) => (row['imageBase64'] ?? '').toString()),
    );
    return AlbumEntry.fromLocalRow(newest);
  }

  int _resolveCreatedAt(
    List<Map<String, Object?>> rows, {
    required int fallback,
  }) {
    final createdAtValues =
        rows
            .map((row) => row['createdAt'] as int?)
            .whereType<int>()
            .where((value) => value > 0)
            .toList()
          ..sort();
    if (createdAtValues.isNotEmpty) {
      return createdAtValues.first;
    }
    return fallback == 0 ? DateTime.now().millisecondsSinceEpoch : fallback;
  }

  String _buildIdentityKey({
    String? drugCode,
    String? approvalNo,
    String? productName,
  }) {
    final trimmedDrugCode = _trimOrEmpty(drugCode);
    if (trimmedDrugCode.isNotEmpty) {
      return 'drugCode:$trimmedDrugCode';
    }

    final trimmedApprovalNo = _trimOrEmpty(approvalNo);
    if (trimmedApprovalNo.isNotEmpty) {
      return 'approvalNo:$trimmedApprovalNo';
    }

    final trimmedProductName = _trimOrEmpty(productName);
    if (trimmedProductName.isNotEmpty) {
      return 'name:$trimmedProductName';
    }

    return 'scan:${DateTime.now().millisecondsSinceEpoch}';
  }

  String _trimOrEmpty(String? value) => (value ?? '').trim();

  String? _trimOrNull(String? value) {
    final trimmed = _trimOrEmpty(value);
    return trimmed.isEmpty ? null : trimmed;
  }

  String _firstNonEmpty(Iterable<String> values) {
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty) {
        return trimmed;
      }
    }
    return '';
  }
}

final albumLocalStore = AlbumLocalStore.instance;

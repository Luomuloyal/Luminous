import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/stores/album_local_store.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/viewmodels/album.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await _resetDatabase();
  });

  tearDown(() async {
    await _resetDatabase();
  });

  test('saveScanRecord stores thumb and original image locally', () async {
    await albumLocalStore.saveScanRecord(
      userId: 'user-a',
      remoteId: 'remote-1',
      drugCode: '86900000000001',
      approvalNo: '国药准字H20000001',
      productName: '阿莫西林胶囊',
      thumbBase64: 'thumb-base64',
      imageBase64: 'image-base64',
      takenAt: 1710000000000,
    );

    final db = await AppDatabase.instance.database;
    final rows = await db.query('album_items');

    expect(rows, hasLength(1));
    expect(rows.first['userId'], 'user-a');
    expect(rows.first['remoteId'], 'remote-1');
    expect(rows.first['thumbBase64'], 'thumb-base64');
    expect(rows.first['imageBase64'], 'image-base64');
  });

  test('loadEntries only returns rows from requested user scope', () async {
    await albumLocalStore.saveScanRecord(
      userId: '',
      productName: '游客记录',
      thumbBase64: 'guest-thumb',
      imageBase64: 'guest-image',
      takenAt: 10,
    );
    await albumLocalStore.saveScanRecord(
      userId: 'user-a',
      productName: '用户A记录',
      thumbBase64: 'user-a-thumb',
      imageBase64: 'user-a-image',
      takenAt: 20,
    );
    await albumLocalStore.saveScanRecord(
      userId: 'user-b',
      productName: '用户B记录',
      thumbBase64: 'user-b-thumb',
      imageBase64: 'user-b-image',
      takenAt: 30,
    );

    final guestEntries = await albumLocalStore.loadEntries(userId: '');
    final userAEntries = await albumLocalStore.loadEntries(userId: 'user-a');
    final userBEntries = await albumLocalStore.loadEntries(userId: 'user-b');

    expect(guestEntries.map((entry) => entry.productName), ['游客记录']);
    expect(userAEntries.map((entry) => entry.productName), ['用户A记录']);
    expect(userBEntries.map((entry) => entry.productName), ['用户B记录']);
  });

  test(
    'upsertRemoteRecords refreshes remote fields and keeps local original',
    () async {
      final db = await AppDatabase.instance.database;
      await db.insert('album_items', {
        'remoteId': 'remote-1',
        'userId': 'user-a',
        'identityKey': 'drugCode:old',
        'drugCode': 'old-code',
        'approvalNo': 'old-approval',
        'productName': '旧药名',
        'filePath': '',
        'thumbBase64': 'old-thumb',
        'imageBase64': 'local-original',
        'takenAt': 10,
        'source': 'scan',
        'createdAt': 10,
      });
      await db.insert('album_items', {
        'remoteId': 'remote-1',
        'userId': 'user-a',
        'identityKey': 'drugCode:dup',
        'drugCode': 'dup-code',
        'approvalNo': 'dup-approval',
        'productName': '重复旧记录',
        'filePath': '',
        'thumbBase64': 'dup-thumb',
        'imageBase64': '',
        'takenAt': 20,
        'source': 'scan',
        'createdAt': 20,
      });

      await albumLocalStore.upsertRemoteRecords('user-a', [
        const ScanRecordItem(
          id: 'remote-1',
          thumbBase64: 'new-thumb',
          drugCode: 'new-code',
          approvalNo: 'new-approval',
          productName: '新药名',
          takenAt: 30,
        ),
      ]);

      final rows = await db.query(
        'album_items',
        where: 'userId = ? AND remoteId = ?',
        whereArgs: ['user-a', 'remote-1'],
      );
      final entries = await albumLocalStore.loadEntries(userId: 'user-a');

      expect(rows, hasLength(1));
      expect(rows.first['thumbBase64'], 'new-thumb');
      expect(rows.first['drugCode'], 'new-code');
      expect(rows.first['approvalNo'], 'new-approval');
      expect(rows.first['productName'], '新药名');
      expect(rows.first['imageBase64'], 'local-original');
      expect(rows.first['createdAt'], 10);

      expect(entries, hasLength(1));
      expect(entries.single.hasOriginalImage, isTrue);
      expect(entries.single.imageBase64, 'local-original');
      expect(entries.single.productName, '新药名');
    },
  );

  test(
    'syncRemoteForUser uploads pending rows and adopts matching guest originals',
    () async {
      final uploadedThumbs = <String>[];
      final store = AlbumLocalStore(
        createRemoteRecord:
            ({
              required userId,
              required thumbBase64,
              String? drugCode,
              String? approvalNo,
              String? productName,
              int? takenAt,
            }) async {
              uploadedThumbs.add('$userId|$thumbBase64|$productName');
              return const IdResult(id: 'remote-pending');
            },
        listRemoteRecords:
            ({required userId, int page = 1, int pageSize = 20}) async {
              return const ScanRecordListResult(
                items: [
                  ScanRecordItem(
                    id: 'remote-shared',
                    thumbBase64: 'remote-thumb',
                    drugCode: 'remote-code',
                    approvalNo: 'remote-approval',
                    productName: '云端新药名',
                    takenAt: 99,
                  ),
                ],
                total: 1,
                page: 1,
                pageSize: 20,
              );
            },
      );

      await store.saveScanRecord(
        userId: 'user-a',
        productName: '待同步记录',
        thumbBase64: 'pending-thumb',
        imageBase64: 'pending-image',
        takenAt: 20,
      );
      await store.saveScanRecord(
        userId: '',
        remoteId: 'remote-shared',
        productName: '游客旧记录',
        thumbBase64: 'guest-thumb',
        imageBase64: 'guest-original',
        takenAt: 10,
      );

      await store.syncRemoteForUser('user-a');

      final db = await AppDatabase.instance.database;
      final userRows = await db.query(
        'album_items',
        where: 'userId = ?',
        whereArgs: ['user-a'],
        orderBy: 'createdAt ASC',
      );
      final guestRows = await db.query(
        'album_items',
        where: 'userId = ?',
        whereArgs: [''],
      );

      expect(uploadedThumbs, ['user-a|pending-thumb|待同步记录']);
      expect(guestRows, isEmpty);
      expect(
        userRows
            .where((row) => row['remoteId'] == 'remote-pending')
            .single['imageBase64'],
        'pending-image',
      );
      expect(
        userRows
            .where((row) => row['remoteId'] == 'remote-shared')
            .single['imageBase64'],
        'guest-original',
      );
      expect(
        userRows
            .where((row) => row['remoteId'] == 'remote-shared')
            .single['productName'],
        '云端新药名',
      );
    },
  );
}

Future<void> _resetDatabase() async {
  await AppDatabase.instance.close();
  final dbPath = await getDatabasesPath();
  await deleteDatabase('$dbPath/luminous.db');
}

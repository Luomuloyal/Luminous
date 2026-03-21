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
    expect(rows.first['remoteId'], 'remote-1');
    expect(rows.first['thumbBase64'], 'thumb-base64');
    expect(rows.first['imageBase64'], 'image-base64');
  });

  test(
    'upsertRemoteRecords refreshes remote fields and keeps local original',
    () async {
      final db = await AppDatabase.instance.database;
      await db.insert('album_items', {
        'remoteId': 'remote-1',
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

      await albumLocalStore.upsertRemoteRecords([
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
        where: 'remoteId = ?',
        whereArgs: ['remote-1'],
      );
      final entries = await albumLocalStore.loadEntries();

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
}

Future<void> _resetDatabase() async {
  await AppDatabase.instance.close();
  final dbPath = await getDatabasesPath();
  await deleteDatabase('$dbPath/luminous.db');
}

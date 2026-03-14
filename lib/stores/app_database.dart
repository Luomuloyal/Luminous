import 'package:sqflite/sqflite.dart';

// AppDatabase：本地 SQLite 数据库
//
// 用途：
// - 存储“我的药品”（用户添加的药品列表）
// - 存储“相册”（拍照/识别产生的照片记录，当前先存元数据，后续再接入真实图片路径）
//
// 注意：
// - 这类本地数据属于“客户端缓存/本地资产”，不依赖后端。
// - 表结构尽量保持稳定；需要变更时通过 version + onUpgrade 做迁移。
class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const String _dbName = 'luminous.db';
  static const int _version = 1;

  Database? _db;

  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // my_medicines：用户添加的药品（来自手动搜索/药物识别）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS my_medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identityKey TEXT NOT NULL UNIQUE,
        drugCode TEXT,
        approvalNo TEXT,
        productName TEXT,
        dosageForm TEXT,
        specification TEXT,
        manufacturer TEXT,
        source TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_my_medicines_createdAt ON my_medicines(createdAt DESC)',
    );

    // album_items：相册记录（先存元数据，后续接入真实图片 filePath）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS album_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identityKey TEXT,
        drugCode TEXT,
        approvalNo TEXT,
        productName TEXT,
        filePath TEXT,
        source TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_items_createdAt ON album_items(createdAt DESC)',
    );
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      return;
    }
    await db.close();
    _db = null;
  }
}


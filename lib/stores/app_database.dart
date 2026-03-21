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
  static const String legacyAlbumUserId = '__legacy__';

  /// 私有构造函数，当前数据库管理器通过单例使用。
  AppDatabase._();

  /// 全局数据库单例。
  static final AppDatabase instance = AppDatabase._();

  /// SQLite 数据库文件名。
  static const String _dbName = 'luminous.db';

  /// 当前数据库 schema 版本号。
  ///
  /// 版本变更时需要同步更新 `_upgradeTables` 中的迁移逻辑。
  static const int _version = 7;

  /// 已打开的数据库实例缓存。
  Database? _db;

  /// 获取可用的数据库实例。
  ///
  /// 首次访问时会打开数据库，后续直接复用缓存实例。
  Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  /// 打开 SQLite 数据库。
  ///
  /// 会在首次创建时执行建表逻辑，在版本升级时执行迁移逻辑。
  Future<Database> _open() async {
    /// 设备上 SQLite 数据库目录路径。
    final dbPath = await getDatabasesPath();

    /// 当前应用数据库完整文件路径。
    final path = '$dbPath/$_dbName';
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _upgradeTables(db, oldVersion, newVersion);
      },
    );
  }

  /// 创建当前版本所需的全部表结构与索引。
  Future<void> _createTables(Database db) async {
    // my_medicines：用户添加的药品（来自手动搜索/药物识别）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS my_medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        identityKey TEXT NOT NULL UNIQUE,
        userId TEXT NOT NULL DEFAULT '',
        remoteId TEXT,
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
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_my_medicines_userId_createdAt ON my_medicines(userId, createdAt DESC)',
    );

    // album_items：相册记录（先存元数据，后续接入真实图片 filePath）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS album_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT,
        userId TEXT NOT NULL DEFAULT '',
        identityKey TEXT,
        drugCode TEXT,
        approvalNo TEXT,
        productName TEXT,
        filePath TEXT,
        thumbBase64 TEXT,
        imageBase64 TEXT,
        imageMimeType TEXT,
        takenAt INTEGER,
        source TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_items_createdAt ON album_items(createdAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_items_remoteId ON album_items(remoteId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_items_userId_createdAt '
      'ON album_items(userId, createdAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_album_items_userId_remoteId '
      'ON album_items(userId, remoteId)',
    );

    // reminders：提醒计划缓存（后端同步源）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT NOT NULL UNIQUE,
        userId TEXT NOT NULL,
        time TEXT NOT NULL,
        drugCode TEXT,
        approvalNo TEXT,
        productName TEXT NOT NULL,
        subtitle TEXT,
        enabled INTEGER NOT NULL,
        repeatRule TEXT NOT NULL,
        method TEXT NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_userId_time ON reminders(userId, time)',
    );

    // checkins：打卡记录缓存
    await db.execute('''
      CREATE TABLE IF NOT EXISTS checkins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT,
        userId TEXT NOT NULL,
        reminderRemoteId TEXT NOT NULL,
        takenAt INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_checkins_userId_takenAt ON checkins(userId, takenAt DESC)',
    );

    // checkin_overrides：今日打卡状态本地覆盖（支持已打卡/未打卡切换）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS checkin_overrides (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        reminderRemoteId TEXT NOT NULL,
        dateKey TEXT NOT NULL,
        done INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        UNIQUE(userId, reminderRemoteId, dateKey)
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_checkin_overrides_userId_dateKey '
      'ON checkin_overrides(userId, dateKey)',
    );
  }

  /// 执行数据库升级迁移。
  ///
  /// 当前仅处理从 v1 升级到 v2 的场景。
  Future<void> _upgradeTables(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // album_items 新增字段：remoteId/thumbBase64/takenAt
      await _tryExecute(db, 'ALTER TABLE album_items ADD COLUMN remoteId TEXT');
      await _tryExecute(
        db,
        'ALTER TABLE album_items ADD COLUMN thumbBase64 TEXT',
      );
      await _tryExecute(
        db,
        'ALTER TABLE album_items ADD COLUMN takenAt INTEGER',
      );

      // 新表：reminders/checkins
      await _createTables(db);
    }

    if (oldVersion < 3) {
      await _tryExecute(
        db,
        "ALTER TABLE my_medicines ADD COLUMN userId TEXT NOT NULL DEFAULT ''",
      );
      await _tryExecute(
        db,
        'ALTER TABLE my_medicines ADD COLUMN remoteId TEXT',
      );
      await _tryExecute(
        db,
        "UPDATE my_medicines SET identityKey = 'guest|' || identityKey "
        "WHERE identityKey NOT LIKE 'guest|%' AND identityKey NOT LIKE 'user:%|%'",
      );
      await _createTables(db);
    }

    if (oldVersion < 4) {
      await _createTables(db);
    }

    if (oldVersion < 5) {
      await _tryExecute(
        db,
        'ALTER TABLE album_items ADD COLUMN imageBase64 TEXT',
      );
      await _createTables(db);
    }

    if (oldVersion < 6) {
      await _tryExecute(
        db,
        "ALTER TABLE album_items ADD COLUMN userId TEXT NOT NULL DEFAULT ''",
      );
      await _tryExecute(
        db,
        "UPDATE album_items SET userId = '$legacyAlbumUserId' WHERE userId = ''",
      );
      await _createTables(db);
    }

    if (oldVersion < 7) {
      await _tryExecute(
        db,
        'ALTER TABLE album_items ADD COLUMN imageMimeType TEXT',
      );
      await _createTables(db);
    }
  }

  /// 尝试执行一条 SQL 语句。
  ///
  /// 用于迁移时的“幂等式”字段新增，避免字段已存在时整个升级失败。
  Future<void> _tryExecute(Database db, String sql) async {
    try {
      await db.execute(sql);
    } catch (_) {
      // Ignore: column/table might already exist on some devices.
    }
  }

  /// 关闭数据库连接并清空实例缓存。
  Future<void> close() async {
    final db = _db;
    if (db == null) {
      return;
    }
    await db.close();
    _db = null;
  }
}

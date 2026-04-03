import 'package:sqflite/sqflite.dart';

// AppDatabase：本地 SQLite 数据库
//
// 用途：
// - 存储“我的药品”（用户添加的药品列表）
// - 存储“相册”（拍照/识别产生的本地图片路径与识别元数据）
//
// 注意：
// - 这类本地数据属于“客户端缓存/本地资产”，不依赖后端。
// - 当前按“全新应用”处理；schema 变化时直接重建本地缓存表。
class AppDatabase {
  /// 私有构造函数，当前数据库管理器通过单例使用。
  AppDatabase._();

  /// 全局数据库单例。
  static final AppDatabase instance = AppDatabase._();

  /// SQLite 数据库文件名。
  static const String _dbName = 'luminous.db';

  /// 当前数据库 schema 版本号。
  static const int _version = 13;

  /// 已打开的数据库实例缓存。
  Database? _db;

  /// 测试环境注入的数据库实例。
  ///
  /// 当该值存在时，业务代码会直接复用它，避免测试依赖真实平台数据库实现。
  Database? _testingDb;

  /// 获取可用的数据库实例。
  ///
  /// 首次访问时会打开数据库，后续直接复用缓存实例。
  Future<Database> get database async {
    final testingDb = _testingDb;
    if (testingDb != null) {
      return testingDb;
    }
    _db ??= await _open();
    return _db!;
  }

  /// 为测试注入一个数据库实例。
  ///
  /// 这会先关闭当前已打开的正式数据库，确保测试与真实持久化互不影响。
  Future<void> useTestingDatabase(Database database) async {
    await close();
    _testingDb = database;
  }

  /// 清除测试注入数据库。
  Future<void> clearTestingDatabase() async {
    final testingDb = _testingDb;
    _testingDb = null;
    if (testingDb != null && testingDb.isOpen) {
      await testingDb.close();
    }
  }

  /// 打开 SQLite 数据库。
  ///
  /// 首次创建时直接建立当前 schema；
  /// 升级或降级时一律丢弃旧本地缓存并按当前 schema 重建。
  Future<Database> _open() async {
    /// 设备上 SQLite 数据库目录路径。
    final dbPath = await getDatabasesPath();

    /// 当前应用数据库完整文件路径。
    final path = '$dbPath/$_dbName';
    return openDatabase(
      path,
      version: _version,
      onCreate: (db, version) async {
        await _createSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _resetSchema(db);
      },
      onDowngrade: (db, oldVersion, newVersion) async {
        await _resetSchema(db);
      },
    );
  }

  /// 创建当前版本的完整 schema。
  Future<void> _createSchema(Database db) async {
    await _createTables(db);
    await _createIndexes(db);
  }

  /// 创建当前版本所需的全部表结构。
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
    // album_items：相册记录（原图/缩略图走文件系统，这里只存路径与元数据）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS album_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        remoteId TEXT,
        userId TEXT NOT NULL DEFAULT '',
        identityKey TEXT,
        drugCode TEXT,
        approvalNo TEXT,
        productName TEXT,
        imagePath TEXT NOT NULL,
        thumbPath TEXT,
        imageMimeType TEXT,
        takenAt INTEGER,
        source TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
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
        medicinesJson TEXT,
        dosage TEXT,
        subtitle TEXT,
        enabled INTEGER NOT NULL,
        repeatRule TEXT NOT NULL,
        method TEXT NOT NULL,
        startDate TEXT,
        endDate TEXT,
        updatedAt INTEGER NOT NULL
      )
    ''');
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
    // today_reminder_snapshots：当天提醒接口快照
    await db.execute('''
      CREATE TABLE IF NOT EXISTS today_reminder_snapshots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL DEFAULT '',
        dateKey TEXT NOT NULL,
        remoteId TEXT NOT NULL,
        time TEXT NOT NULL,
        title TEXT NOT NULL,
        dosage TEXT,
        subtitle TEXT,
        serverDone INTEGER NOT NULL,
        position INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');
  }

  /// 直接丢弃旧 schema，并按当前版本重建本地缓存。
  Future<void> _resetSchema(Database db) async {
    await db.execute('DROP TABLE IF EXISTS my_medicines');
    await db.execute('DROP TABLE IF EXISTS album_items');
    await db.execute('DROP TABLE IF EXISTS reminders');
    await db.execute('DROP TABLE IF EXISTS checkins');
    await db.execute('DROP TABLE IF EXISTS checkin_overrides');
    await db.execute('DROP TABLE IF EXISTS today_reminder_snapshots');
    await _createSchema(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_my_medicines_createdAt ON my_medicines(createdAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_my_medicines_userId_createdAt '
      'ON my_medicines(userId, createdAt DESC)',
    );

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

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_reminders_userId_time ON reminders(userId, time)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_checkins_userId_takenAt ON checkins(userId, takenAt DESC)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_checkin_overrides_userId_dateKey '
      'ON checkin_overrides(userId, dateKey)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_today_reminder_snapshots_userId_dateKey_position '
      'ON today_reminder_snapshots(userId, dateKey, position)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_today_reminder_snapshots_userId_dateKey_remoteId '
      'ON today_reminder_snapshots(userId, dateKey, remoteId)',
    );
  }

  /// 关闭数据库连接并清空实例缓存。
  Future<void> close() async {
    final testingDb = _testingDb;
    if (testingDb != null) {
      if (testingDb.isOpen) {
        await testingDb.close();
      }
      _testingDb = null;
    }

    final db = _db;
    if (db == null) {
      return;
    }
    await db.close();
    _db = null;
  }
}

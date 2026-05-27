import 'package:sqflite/sqflite.dart';

/// 纯 Dart 的轻量假数据库。
///
/// 目前只覆盖仓库内测试真正会用到的那部分 sqflite 能力，
/// 用来避免 host 侧测试再依赖 `sqflite_common_ffi -> sqlite3`。
class FakeSqfliteDatabase implements Database, Transaction {
  final Map<String, List<Map<String, Object?>>> _tables =
      <String, List<Map<String, Object?>>>{};
  final Map<String, int> _autoIds = <String, int>{};

  bool _isOpen = true;

  @override
  Database get database => this;

  @override
  String get path => ':memory:';

  @override
  bool get isOpen => _isOpen;

  @override
  Future<void> close() async {
    _isOpen = false;
  }

  @override
  Future<T> transaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) async {
    _ensureOpen();
    return action(this);
  }

  @override
  Future<T> readTransaction<T>(Future<T> Function(Transaction txn) action) {
    _ensureOpen();
    return action(this);
  }

  @override
  Future<void> execute(String sql, [List<Object?>? arguments]) async {
    _ensureOpen();
  }

  @override
  Future<int> insert(
    String table,
    Map<String, Object?> values, {
    String? nullColumnHack,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    _ensureOpen();
    final row = Map<String, Object?>.from(values);
    row['id'] = (row['id'] as int?) ?? _nextId(table);
    _table(table).add(row);
    return row['id'] as int;
  }

  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    _ensureOpen();
    var rows = _table(table)
        .where((row) => _matchesWhere(row, where, whereArgs))
        .map((row) => Map<String, Object?>.from(row))
        .toList();

    _sortRows(rows, orderBy);

    if (offset != null && offset > 0) {
      rows = offset >= rows.length
          ? <Map<String, Object?>>[]
          : rows.sublist(offset);
    }
    if (limit != null && limit >= 0 && rows.length > limit) {
      rows = rows.take(limit).toList();
    }

    if (columns != null) {
      rows = rows
          .map(
            (row) => <String, Object?>{
              for (final column in columns) column: row[column],
            },
          )
          .toList();
    }

    return rows;
  }

  @override
  Future<int> update(
    String table,
    Map<String, Object?> values, {
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    _ensureOpen();
    var changed = 0;
    for (final row in _table(table)) {
      if (_matchesWhere(row, where, whereArgs)) {
        row.addAll(values);
        changed += 1;
      }
    }
    return changed;
  }

  @override
  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    _ensureOpen();
    final rows = _table(table);
    final originalLength = rows.length;
    rows.removeWhere((row) => _matchesWhere(row, where, whereArgs));
    return originalLength - rows.length;
  }

  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) {
    throw UnsupportedError('rawQuery is not needed by current tests');
  }

  @override
  Future<QueryCursor> rawQueryCursor(
    String sql,
    List<Object?>? arguments, {
    int? bufferSize,
  }) {
    throw UnsupportedError('rawQueryCursor is not needed by current tests');
  }

  @override
  Future<QueryCursor> queryCursor(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
    int? bufferSize,
  }) {
    throw UnsupportedError('queryCursor is not needed by current tests');
  }

  @override
  Future<int> rawInsert(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('rawInsert is not needed by current tests');
  }

  @override
  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('rawUpdate is not needed by current tests');
  }

  @override
  Future<int> rawDelete(String sql, [List<Object?>? arguments]) {
    throw UnsupportedError('rawDelete is not needed by current tests');
  }

  @override
  Batch batch() {
    throw UnsupportedError('batch is not needed by current tests');
  }

  @override
  Future<T> devInvokeMethod<T>(String method, [Object? arguments]) {
    throw UnsupportedError('devInvokeMethod is not needed by current tests');
  }

  @override
  Future<T> devInvokeSqlMethod<T>(
    String method,
    String sql, [
    List<Object?>? arguments,
  ]) {
    throw UnsupportedError('devInvokeSqlMethod is not needed by current tests');
  }

  List<Map<String, Object?>> _table(String table) {
    return _tables.putIfAbsent(table, () => <Map<String, Object?>>[]);
  }

  int _nextId(String table) {
    final next = (_autoIds[table] ?? 0) + 1;
    _autoIds[table] = next;
    return next;
  }

  void _ensureOpen() {
    if (!_isOpen) {
      throw StateError('Database is closed');
    }
  }

  bool _matchesWhere(
    Map<String, Object?> row,
    String? where,
    List<Object?>? whereArgs,
  ) {
    if (where == null || where.trim().isEmpty) {
      return true;
    }

    final normalizedWhere = where.replaceAll(RegExp(r'\s+'), ' ').trim();
    final args = whereArgs ?? const <Object?>[];

    if (normalizedWhere == 'userId = ?') {
      return row['userId'] == args[0];
    }
    if (normalizedWhere == 'userId = ? AND takenAt >= ? AND takenAt < ?') {
      final takenAt = (row['takenAt'] as int?) ?? 0;
      return row['userId'] == args[0] &&
          takenAt >= (args[1] as int? ?? 0) &&
          takenAt < (args[2] as int? ?? 0);
    }
    if (normalizedWhere == 'userId = ? OR userId = ?') {
      return row['userId'] == args[0] || row['userId'] == args[1];
    }
    if (normalizedWhere == 'userId = ? AND remoteId = ?') {
      return row['userId'] == args[0] && row['remoteId'] == args[1];
    }
    if (normalizedWhere ==
        "userId = ? AND (remoteId IS NULL OR remoteId = '')") {
      final remoteId = row['remoteId'];
      final missingRemoteId =
          remoteId == null || remoteId.toString().trim().isEmpty;
      return row['userId'] == args[0] && missingRemoteId;
    }
    if (normalizedWhere == 'id = ?') {
      return row['id'] == args[0];
    }
    if (normalizedWhere.startsWith('id IN (')) {
      return args.contains(row['id']);
    }
    if (normalizedWhere ==
        "(userId = ? OR userId = ?) AND (remoteId IS NULL OR remoteId = '')") {
      final matchesUser = row['userId'] == args[0] || row['userId'] == args[1];
      final remoteId = row['remoteId'];
      final missingRemoteId =
          remoteId == null || remoteId.toString().trim().isEmpty;
      return matchesUser && missingRemoteId;
    }
    if (normalizedWhere.startsWith('remoteId IN (') &&
        normalizedWhere.endsWith('AND (userId = ? OR userId = ?)')) {
      final remoteIdArgs = args.take(args.length - 2).toSet();
      final userArgs = args.skip(args.length - 2).toSet();
      return remoteIdArgs.contains(row['remoteId']) &&
          userArgs.contains(row['userId']);
    }
    if (normalizedWhere.startsWith('remoteId IN (') &&
        normalizedWhere.endsWith(
          'AND (userId = ? OR userId = ? OR userId = ?)',
        )) {
      final remoteIdArgs = args.take(args.length - 3).toSet();
      final userArgs = args.skip(args.length - 3).toSet();
      return remoteIdArgs.contains(row['remoteId']) &&
          userArgs.contains(row['userId']);
    }

    throw UnsupportedError('Unsupported where clause in fake db: $where');
  }

  void _sortRows(List<Map<String, Object?>> rows, String? orderBy) {
    if (orderBy == null || orderBy.trim().isEmpty) {
      return;
    }

    final normalizedOrderBy = orderBy.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalizedOrderBy == 'createdAt ASC, id ASC') {
      rows.sort((a, b) {
        final createdAtCompare = ((a['createdAt'] as int?) ?? 0).compareTo(
          (b['createdAt'] as int?) ?? 0,
        );
        if (createdAtCompare != 0) {
          return createdAtCompare;
        }
        return ((a['id'] as int?) ?? 0).compareTo((b['id'] as int?) ?? 0);
      });
      return;
    }

    if (normalizedOrderBy == 'createdAt ASC') {
      rows.sort(
        (a, b) => ((a['createdAt'] as int?) ?? 0).compareTo(
          (b['createdAt'] as int?) ?? 0,
        ),
      );
      return;
    }

    if (normalizedOrderBy == 'time ASC, id ASC') {
      rows.sort((a, b) {
        final timeCompare = (a['time'] as String? ?? '')
            .compareTo(b['time'] as String? ?? '');
        if (timeCompare != 0) return timeCompare;
        return ((a['id'] as int?) ?? 0).compareTo((b['id'] as int?) ?? 0);
      });
      return;
    }

    if (normalizedOrderBy == 'takenAt DESC, id DESC') {
      rows.sort((a, b) {
        final takenAtCompare = ((b['takenAt'] as int?) ?? 0)
            .compareTo((a['takenAt'] as int?) ?? 0);
        if (takenAtCompare != 0) return takenAtCompare;
        return ((b['id'] as int?) ?? 0).compareTo((a['id'] as int?) ?? 0);
      });
      return;
    }

    if (normalizedOrderBy ==
        'COALESCE(takenAt, createdAt) DESC, createdAt DESC, id DESC') {
      rows.sort((a, b) {
        final aTakenAt =
            (a['takenAt'] as int?) ?? (a['createdAt'] as int?) ?? 0;
        final bTakenAt =
            (b['takenAt'] as int?) ?? (b['createdAt'] as int?) ?? 0;
        final takenAtCompare = bTakenAt.compareTo(aTakenAt);
        if (takenAtCompare != 0) {
          return takenAtCompare;
        }

        final createdAtCompare = ((b['createdAt'] as int?) ?? 0).compareTo(
          (a['createdAt'] as int?) ?? 0,
        );
        if (createdAtCompare != 0) {
          return createdAtCompare;
        }

        return ((b['id'] as int?) ?? 0).compareTo((a['id'] as int?) ?? 0);
      });
      return;
    }

    throw UnsupportedError('Unsupported orderBy in fake db: $orderBy');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnsupportedError(
      'FakeSqfliteDatabase does not implement ${invocation.memberName}',
    );
  }
}

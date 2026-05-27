import 'package:flutter/foundation.dart';
import 'package:luminous/core/local_storage/app_database.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

import 'package:sqflite/sqflite.dart';

import 'today_reminder_sql.dart';
import 'today_reminder_store.dart';

/// 今日提醒快照、本地打卡状态与本地覆盖状态的统一读取/写入入口。
class TodayReminderLocalStore implements TodayReminderStore {
  TodayReminderLocalStore._();

  static final TodayReminderLocalStore instance = TodayReminderLocalStore._();
  final Map<String, List<ReminderItem>> _webSnapshots =
      <String, List<ReminderItem>>{};
  final Map<String, Map<String, bool>> _webOverrides =
      <String, Map<String, bool>>{};
  final Map<String, Set<String>> _webDoneSets = <String, Set<String>>{};

  @override
  ({int start, int end, String dateKey}) todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    final dateKey =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    return (start: start, end: end, dateKey: dateKey);
  }

  @override
  String resolveDateKey([String? date]) {
    final trimmed = (date ?? '').trim();
    return trimmed.isEmpty ? todayRange().dateKey : trimmed;
  }

  @override
  Future<void> replaceTodaySnapshot({
    required String? userId,
    String? date,
    required List<ReminderItem> items,
  }) async {
    if (kIsWeb) {
      _webSnapshots[_snapshotKey(userId, date: date)] = items
          .map(
            (item) => ReminderItem(
              id: item.id,
              time: item.time,
              title: item.title,
              dosage: item.dosage,
              subtitle: item.subtitle,
              done: item.done,
            ),
          )
          .toList(growable: false);
      return;
    }
    final db = await AppDatabase.instance.database;
    final uid = (userId ?? '').trim();
    final dateKey = resolveDateKey(date);
    final updatedAt = DateTime.now().millisecondsSinceEpoch;

    await db.transaction((txn) async {
      await txn.delete(
        'today_reminder_snapshots',
        where: 'userId = ? AND dateKey = ?',
        whereArgs: [uid, dateKey],
      );

      for (var index = 0; index < items.length; index++) {
        final item = items[index];
        await txn.insert('today_reminder_snapshots', {
          'userId': uid,
          'dateKey': dateKey,
          'remoteId': item.id.trim(),
          'time': item.time.trim(),
          'title': item.title.trim(),
          'dosage': item.dosage.trim(),
          'subtitle': item.subtitle.trim(),
          'serverDone': item.done ? 1 : 0,
          'position': index,
          'updatedAt': updatedAt,
        });
      }
    });
  }

  @override
  Future<Map<String, bool>> loadTodayOverrides(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const {};
    }

    if (kIsWeb) {
      return Map<String, bool>.from(
        _webOverrides[_todayStateKey(uid)] ?? const <String, bool>{},
      );
    }

    try {
      final db = await AppDatabase.instance.database;
      final range = todayRange();
      final rows = await db.query(
        'checkin_overrides',
        columns: ['reminderRemoteId', 'done'],
        where: 'userId = ? AND dateKey = ?',
        whereArgs: [uid, range.dateKey],
      );
      return {
        for (final row in rows)
          (row['reminderRemoteId'] ?? '').toString().trim():
              (row['done'] as int? ?? 0) == 1,
      }..removeWhere((key, value) => key.isEmpty);
    } catch (_) {
      return const {};
    }
  }

  @override
  Future<void> saveTodayOverride({
    required String userId,
    required String reminderId,
    required bool done,
  }) async {
    if (kIsWeb) {
      final uid = userId.trim();
      final id = reminderId.trim();
      if (uid.isEmpty || id.isEmpty) {
        return;
      }
      final overrides = _webOverrides.putIfAbsent(
        _todayStateKey(uid),
        () => <String, bool>{},
      );
      overrides[id] = done;
      return;
    }
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    await db.insert('checkin_overrides', {
      'userId': userId.trim(),
      'reminderRemoteId': reminderId.trim(),
      'dateKey': range.dateKey,
      'done': done ? 1 : 0,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> replaceTodayCheckin({
    required String userId,
    required String reminderId,
    String? remoteId,
    required int takenAt,
  }) async {
    if (kIsWeb) {
      final uid = userId.trim();
      final id = reminderId.trim();
      if (uid.isEmpty || id.isEmpty) {
        return;
      }
      final doneSet = _webDoneSets.putIfAbsent(
        _todayStateKey(uid),
        () => <String>{},
      );
      doneSet
        ..remove(id)
        ..add(id);
      return;
    }
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    await db.delete(
      'checkins',
      where:
          'userId = ? AND reminderRemoteId = ? AND takenAt >= ? AND takenAt < ?',
      whereArgs: [userId, reminderId, range.start, range.end],
    );
    await db.insert('checkins', {
      'remoteId': remoteId ?? '',
      'userId': userId,
      'reminderRemoteId': reminderId,
      'takenAt': takenAt,
      'createdAt': takenAt,
    });
  }

  @override
  Future<void> deleteTodayCheckin({
    required String userId,
    required String reminderId,
  }) async {
    if (kIsWeb) {
      final uid = userId.trim();
      final id = reminderId.trim();
      if (uid.isEmpty || id.isEmpty) {
        return;
      }
      _webDoneSets[_todayStateKey(uid)]?.remove(id);
      return;
    }
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    await db.delete(
      'checkins',
      where:
          'userId = ? AND reminderRemoteId = ? AND takenAt >= ? AND takenAt < ?',
      whereArgs: [userId, reminderId, range.start, range.end],
    );
  }

  @override
  Future<List<ReminderItem>> loadTodaySnapshotItems(
    String? userId, {
    String? date,
    Map<String, bool>? overrides,
  }) async {
    final snapshot = await _loadBaseSnapshotItems(userId, date: date);
    if (snapshot.isEmpty) {
      return const [];
    }
    return applyTodayState(userId, items: snapshot, overrides: overrides);
  }

  @override
  Future<List<ReminderItem>> applyTodayState(
    String? userId, {
    required List<ReminderItem> items,
    Map<String, bool>? overrides,
  }) async {
    if (items.isEmpty) {
      return const [];
    }

    final uid = (userId ?? '').trim();
    if (kIsWeb) {
      final doneSet = _webDoneSets[_todayStateKey(uid)] ?? const <String>{};
      return _applyDoneState(items, doneSet, overrides);
    }

    final db = await AppDatabase.instance.database;
    final range = todayRange();
    final doneSet = await loadTodayDoneSet(
      db: db,
      userId: uid,
      startMs: range.start,
      endMs: range.end,
    );
    return _applyDoneState(items, doneSet, overrides);
  }

  @override
  Future<List<ReminderItem>> buildTodayItemsFromPlans(
    String? userId,
    List<ReminderPlan> plans,
  ) async {
    final today = resolveDateKey();
    final baseItems = plans
        .where(
          (plan) =>
              plan.enabled &&
              _supportsLocalCheckin(plan) &&
              _isPlanActiveOnDate(plan, today),
        )
        .map(
          (plan) => ReminderItem(
            id: plan.id.trim(),
            time: plan.time.trim(),
            title: plan.productName.trim().isEmpty
                ? AppI18nText.pick(zh: '用药提醒', en: 'Medication Reminder')
                : plan.productName.trim(),
            dosage: plan.dosage.trim(),
            subtitle: plan.subtitle.trim(),
            done: false,
          ),
        )
        .toList(growable: false);

    final overrides = await loadTodayOverrides(userId);
    return applyTodayState(userId, items: baseItems, overrides: overrides);
  }

  @override
  Future<List<HomeCheckInRecordData>> loadRecentCheckinRecords(
    String? userId, {
    int maxDays = 7,
    int maxItems = 120,
  }) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const [];
    }

    final normalizedDays = maxDays <= 0 ? 7 : maxDays;
    final normalizedItems = maxItems <= 0 ? 120 : maxItems;
    final todayKey = resolveDateKey();
    final items = await loadTodaySnapshotItems(uid);
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    final todayRecords = await loadTodayCheckinRecordsFromDb(
      db: db,
      userId: uid,
      startMs: range.start,
      endMs: range.end,
      todayKey: todayKey,
      items: items,
    );
    if (kIsWeb) {
      return todayRecords;
    }

    final reminderMetaMap = await loadReminderMetaMap(db, uid);
    final rangeStartDate = DateTime.now().subtract(
      Duration(days: normalizedDays - 1),
    );
    final rangeStart = DateTime(
      rangeStartDate.year,
      rangeStartDate.month,
      rangeStartDate.day,
    ).millisecondsSinceEpoch;
    final rows = await db.query(
      'checkins',
      columns: ['reminderRemoteId', 'takenAt'],
      where: 'userId = ? AND takenAt >= ?',
      whereArgs: [uid, rangeStart],
      orderBy: 'takenAt DESC, id DESC',
      limit: normalizedItems,
    );

    final results = <HomeCheckInRecordData>[...todayRecords];
    final seen = <String>{
      for (final item in todayRecords) '${item.dateKey}|${item.reminderId}',
    };

    for (final row in rows) {
      final reminderId = (row['reminderRemoteId'] ?? '').toString().trim();
      if (reminderId.isEmpty) {
        continue;
      }
      final takenAt = (row['takenAt'] as int?) ?? 0;
      if (takenAt <= 0) {
        continue;
      }
      final dateKey = dateKeyFromTimestamp(takenAt);
      if (dateKey == todayKey) {
        continue;
      }
      final dedupeKey = '$dateKey|$reminderId';
      if (!seen.add(dedupeKey)) {
        continue;
      }
      final meta = reminderMetaMap[reminderId];
      results.add(
        HomeCheckInRecordData(
          dateKey: dateKey,
          reminderId: reminderId,
          title: meta?.title ?? AppI18nText.pick(zh: '用药提醒', en: 'Medication'),
          reminderTime: meta?.time ?? '',
          done: true,
          takenAt: takenAt,
        ),
      );
    }

    results.sort((a, b) {
      final dateCompare = b.dateKey.compareTo(a.dateKey);
      if (dateCompare != 0) {
        return dateCompare;
      }
      final takenCompare = (b.takenAt ?? -1).compareTo(a.takenAt ?? -1);
      if (takenCompare != 0) {
        return takenCompare;
      }
      return a.reminderTime.compareTo(b.reminderTime);
    });

    return results;
  }

  // -- 私有辅助方法 --

  bool _isPlanActiveOnDate(ReminderPlan plan, String dateKey) {
    final start = plan.startDate.trim();
    final end = plan.endDate.trim();
    final afterStart = start.isEmpty || dateKey.compareTo(start) >= 0;
    final beforeEnd = end.isEmpty || dateKey.compareTo(end) <= 0;
    return afterStart && beforeEnd;
  }

  Future<List<ReminderItem>> _loadBaseSnapshotItems(
    String? userId, {
    String? date,
  }) async {
    if (kIsWeb) {
      final snapshot = _webSnapshots[_snapshotKey(userId, date: date)];
      if (snapshot == null || snapshot.isEmpty) {
        return const [];
      }
      return snapshot
          .map(
            (item) => ReminderItem(
              id: item.id,
              time: item.time,
              title: item.title,
              dosage: item.dosage,
              subtitle: item.subtitle,
              done: item.done,
            ),
          )
          .toList(growable: false);
    }

    final db = await AppDatabase.instance.database;
    final uid = (userId ?? '').trim();
    final dateKey = resolveDateKey(date);
    final rows = await loadTodaySnapshotRows(
      db: db,
      userId: uid,
      dateKey: dateKey,
    );
    if (rows.isEmpty) {
      return const [];
    }

    return mapSnapshotRows(rows);
  }

  bool _supportsLocalCheckin(ReminderPlan plan) {
    final repeatRule = plan.repeatRule.trim().toLowerCase();
    return repeatRule.isEmpty || repeatRule == 'daily';
  }

  bool resolveDoneState({
    required String remoteId,
    required Set<String> doneSet,
    Map<String, bool>? overrides,
    bool serverDone = false,
  }) {
    final trimmedId = remoteId.trim();
    if (trimmedId.isEmpty) {
      return serverDone;
    }
    final override = overrides?[trimmedId];
    if (override != null) {
      return override;
    }
    return doneSet.contains(trimmedId) || serverDone;
  }

  String _snapshotKey(String? userId, {String? date}) {
    final uid = (userId ?? '').trim();
    return '$uid|${resolveDateKey(date)}';
  }

  String _todayStateKey(String userId) {
    return '$userId|${todayRange().dateKey}';
  }

  List<ReminderItem> _applyDoneState(
    List<ReminderItem> items,
    Set<String> doneSet,
    Map<String, bool>? overrides,
  ) {
    return items
        .map(
          (item) => ReminderItem(
            id: item.id,
            time: item.time,
            title: item.title.trim().isEmpty
                ? AppI18nText.pick(zh: '用药提醒', en: 'Medication Reminder')
                : item.title.trim(),
            dosage: item.dosage,
            subtitle: item.subtitle,
            done: resolveDoneState(
              remoteId: item.id,
              doneSet: doneSet,
              overrides: overrides,
              serverDone: item.done,
            ),
          ),
        )
        .toList(growable: false);
  }
}

final todayReminderLocalStore = TodayReminderLocalStore.instance;

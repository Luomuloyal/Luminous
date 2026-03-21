import 'package:flutter/material.dart';
import 'package:luminous/components/home.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:sqflite/sqflite.dart';

/// 今日提醒与本地打卡覆盖状态的统一读取/写入入口。
class TodayReminderLocalStore {
  TodayReminderLocalStore._();

  static final TodayReminderLocalStore instance = TodayReminderLocalStore._();

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

  Future<Map<String, bool>> loadTodayOverrides(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const {};
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

  Future<void> saveTodayOverride({
    required String userId,
    required String reminderId,
    required bool done,
  }) async {
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

  Future<void> replaceTodayCheckin({
    required String userId,
    required String reminderId,
    String? remoteId,
    required int takenAt,
  }) async {
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

  Future<void> deleteTodayCheckin({
    required String userId,
    required String reminderId,
  }) async {
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    await db.delete(
      'checkins',
      where:
          'userId = ? AND reminderRemoteId = ? AND takenAt >= ? AND takenAt < ?',
      whereArgs: [userId, reminderId, range.start, range.end],
    );
  }

  Future<List<HomeReminderItemData>> loadHomeReminderItems(
    String? userId, {
    Map<String, bool>? overrides,
  }) async {
    final rows = await _loadReminderRows(userId);
    if (rows.isEmpty) {
      return const [];
    }

    final doneSet = await _loadDoneSet(userId);
    return rows.map((row) {
      final remoteId = (row['remoteId'] ?? '').toString().trim();
      final time = (row['time'] ?? '').toString().trim();
      final title = (row['productName'] ?? '').toString().trim();
      final subtitle = (row['subtitle'] ?? '').toString().trim();
      final done = resolveDoneState(
        remoteId: remoteId,
        doneSet: doneSet,
        overrides: overrides,
      );
      final combinedTitle = time.isEmpty ? title : '$time $title';
      return HomeReminderItemData(
        icon: Icons.access_time_rounded,
        title: combinedTitle.isEmpty ? '用药提醒' : combinedTitle,
        subtitle: subtitle.isEmpty ? '系统通知提醒' : subtitle,
        done: done,
      );
    }).toList();
  }

  Future<List<ReminderItem>> loadCheckInReminderItems(
    String? userId, {
    Map<String, bool>? overrides,
  }) async {
    final rows = await _loadReminderRows(userId);
    if (rows.isEmpty) {
      return const [];
    }

    final doneSet = await _loadDoneSet(userId);
    return rows.map((row) {
      final remoteId = (row['remoteId'] ?? '').toString().trim();
      final time = (row['time'] ?? '').toString().trim();
      final title = (row['productName'] ?? '').toString().trim();
      final subtitle = (row['subtitle'] ?? '').toString().trim();
      final done = resolveDoneState(
        remoteId: remoteId,
        doneSet: doneSet,
        overrides: overrides,
      );
      return ReminderItem(
        id: remoteId,
        time: time,
        title: title.isEmpty ? '用药提醒' : title,
        subtitle: subtitle.isEmpty ? '系统通知提醒' : subtitle,
        done: done,
      );
    }).toList();
  }

  bool resolveDoneState({
    required String remoteId,
    required Set<String> doneSet,
    Map<String, bool>? overrides,
  }) {
    final trimmedId = remoteId.trim();
    if (trimmedId.isEmpty) {
      return false;
    }
    final override = overrides?[trimmedId];
    if (override != null) {
      return override;
    }
    return doneSet.contains(trimmedId);
  }

  Future<List<Map<String, dynamic>>> _loadReminderRows(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const [];
    }
    final db = await AppDatabase.instance.database;
    return db.query(
      'reminders',
      where: 'userId = ? AND enabled = 1',
      whereArgs: [uid],
      orderBy: 'time ASC',
    );
  }

  Future<Set<String>> _loadDoneSet(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      return const {};
    }
    final db = await AppDatabase.instance.database;
    final range = todayRange();
    final rows = await db.query(
      'checkins',
      columns: ['reminderRemoteId'],
      where: 'userId = ? AND takenAt >= ? AND takenAt < ?',
      whereArgs: [uid, range.start, range.end],
    );
    return rows
        .map((row) => (row['reminderRemoteId'] ?? '').toString().trim())
        .where((id) => id.isNotEmpty)
        .toSet();
  }
}

final todayReminderLocalStore = TodayReminderLocalStore.instance;

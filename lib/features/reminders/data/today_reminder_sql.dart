import 'package:sqflite/sqflite.dart';

import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/shared/models/home.dart';

/// 从快照表中加载原始行。
Future<List<Map<String, dynamic>>> loadTodaySnapshotRows({
  required Database db,
  required String userId,
  required String dateKey,
}) async {
  return db.query(
    'today_reminder_snapshots',
    where: 'userId = ? AND dateKey = ?',
    whereArgs: [userId, dateKey],
    orderBy: 'position ASC, id ASC',
  );
}

/// 将快照行映射为 [ReminderItem] 列表。
List<ReminderItem> mapSnapshotRows(List<Map<String, dynamic>> rows) {
  return rows
      .map((row) {
        final remoteId = (row['remoteId'] ?? '').toString().trim();
        final time = (row['time'] ?? '').toString().trim();
        final title = (row['title'] ?? '').toString().trim();
        final dosage = (row['dosage'] ?? '').toString().trim();
        final subtitle = (row['subtitle'] ?? '').toString().trim();
        return ReminderItem(
          id: remoteId,
          time: time,
          title: title.isEmpty
              ? AppI18nText.pick(zh: '用药提醒', en: 'Medication Reminder')
              : title,
          dosage: dosage,
          subtitle: subtitle,
          done: (row['serverDone'] as int? ?? 0) == 1,
        );
      })
      .toList(growable: false);
}

/// 加载今日打卡集合。
Future<Set<String>> loadTodayDoneSet({
  required Database db,
  required String userId,
  required int startMs,
  required int endMs,
}) async {
  final rows = await db.query(
    'checkins',
    columns: ['reminderRemoteId'],
    where: 'userId = ? AND takenAt >= ? AND takenAt < ?',
    whereArgs: [userId, startMs, endMs],
  );
  return rows
      .map((row) => (row['reminderRemoteId'] ?? '').toString().trim())
      .where((id) => id.isNotEmpty)
      .toSet();
}

/// 加载今日打卡记录。
Future<List<HomeCheckInRecordData>> loadTodayCheckinRecordsFromDb({
  required Database db,
  required String userId,
  required int startMs,
  required int endMs,
  required String todayKey,
  required List<ReminderItem> items,
}) async {
  final rows = await db.query(
    'checkins',
    columns: ['reminderRemoteId', 'takenAt'],
    where: 'userId = ? AND takenAt >= ? AND takenAt < ?',
    whereArgs: [userId, startMs, endMs],
    orderBy: 'takenAt DESC, id DESC',
  );
  final takenAtMap = <String, int>{
    for (final row in rows)
      (row['reminderRemoteId'] ?? '').toString().trim():
          (row['takenAt'] as int?) ?? 0,
  }..removeWhere((key, value) => key.isEmpty || value <= 0);

  return items
      .map(
        (item) => HomeCheckInRecordData(
          dateKey: todayKey,
          reminderId: item.id.trim(),
          title: item.title.trim().isEmpty
              ? AppI18nText.pick(zh: '用药提醒', en: 'Medication')
              : item.title.trim(),
          reminderTime: item.time.trim(),
          done: item.done,
          takenAt: takenAtMap[item.id.trim()],
        ),
      )
      .where((item) => item.reminderId.isNotEmpty)
      .toList(growable: false);
}

/// 提醒元数据。
class ReminderMeta {
  const ReminderMeta({required this.time, required this.title});

  final String time;
  final String title;
}

/// 加载提醒元数据映射。
Future<Map<String, ReminderMeta>> loadReminderMetaMap(
  Database db,
  String userId,
) async {
  final rows = await db.query(
    'reminders',
    columns: ['remoteId', 'time', 'productName'],
    where: 'userId = ?',
    whereArgs: [userId],
    orderBy: 'time ASC, id ASC',
  );
  return <String, ReminderMeta>{
    for (final row in rows)
      (row['remoteId'] ?? '').toString().trim(): ReminderMeta(
        time: (row['time'] ?? '').toString().trim(),
        title: (row['productName'] ?? '').toString().trim(),
      ),
  }..removeWhere((key, value) => key.isEmpty);
}

/// 从毫秒时间戳生成日期键。
String dateKeyFromTimestamp(int millis) {
  final date = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

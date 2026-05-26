import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/reminders/data/today_reminder_sql.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/utils/app_i18n_text.dart';

import 'support/fake_sqflite_database.dart';

void main() {
  group('dateKeyFromTimestamp', () {
    test('returns correct date key for known timestamp', () {
      final millis = DateTime.utc(2026, 5, 26, 12, 0, 0).millisecondsSinceEpoch;
      expect(dateKeyFromTimestamp(millis), '2026-05-26');
    });

    test('pads single-digit month and day', () {
      final millis = DateTime.utc(2026, 1, 5, 0, 0, 0).millisecondsSinceEpoch;
      expect(dateKeyFromTimestamp(millis), '2026-01-05');
    });
  });

  group('mapSnapshotRows', () {
    test('returns empty list for empty rows', () {
      expect(mapSnapshotRows([]), isEmpty);
    });

    test('maps rows to ReminderItem with correct fields', () {
      final rows = [
        <String, dynamic>{
          'remoteId': 'rem-1',
          'time': '08:30',
          'title': '阿莫西林',
          'dosage': '1粒',
          'subtitle': '早餐后',
          'serverDone': 1,
        },
        <String, dynamic>{
          'remoteId': 'rem-2',
          'time': '20:00',
          'title': '',
          'dosage': '',
          'subtitle': '晚饭后',
          'serverDone': 0,
        },
      ];

      final items = mapSnapshotRows(rows);
      expect(items.length, 2);

      expect(items[0].id, 'rem-1');
      expect(items[0].time, '08:30');
      expect(items[0].title, '阿莫西林');
      expect(items[0].dosage, '1粒');
      expect(items[0].subtitle, '早餐后');
      expect(items[0].done, isTrue);

      expect(items[1].id, 'rem-2');
      expect(items[1].time, '20:00');
      expect(items[1].done, isFalse);
    });

    test('uses fallback title when title is empty', () {
      final rows = [
        <String, dynamic>{
          'remoteId': 'rem-x',
          'time': '12:00',
          'title': '',
          'dosage': '',
          'subtitle': '',
          'serverDone': 0,
        },
      ];

      final items = mapSnapshotRows(rows);
      final fallbackZh = AppI18nText.pick(zh: '用药提醒', en: 'Medication Reminder');
      expect(items[0].title, fallbackZh);
    });
  });

  group('loadTodayDoneSet', () {
    test('returns empty set for empty table', () async {
      final db = FakeSqfliteDatabase();
      final result = await loadTodayDoneSet(
        db: db,
        userId: 'u1',
        startMs: 0,
        endMs: 999999999999,
      );
      expect(result, isEmpty);
    });

    test('returns done ids for matching checkins', () async {
      final db = FakeSqfliteDatabase();
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('checkins', {
        'userId': 'u1',
        'reminderRemoteId': 'rem-1',
        'takenAt': now,
      });
      await db.insert('checkins', {
        'userId': 'u1',
        'reminderRemoteId': 'rem-2',
        'takenAt': now,
      });
      await db.insert('checkins', {
        'userId': 'u2',
        'reminderRemoteId': 'rem-3',
        'takenAt': now,
      });

      final result = await loadTodayDoneSet(
        db: db,
        userId: 'u1',
        startMs: now - 1000,
        endMs: now + 1000,
      );
      expect(result, {'rem-1', 'rem-2'});
    });
  });

  group('loadReminderMetaMap', () {
    test('returns empty map for empty table', () async {
      final db = FakeSqfliteDatabase();
      final result = await loadReminderMetaMap(db, 'u1');
      expect(result, isEmpty);
    });

    test('returns meta map for matching rows', () async {
      final db = FakeSqfliteDatabase();
      await db.insert('reminders', {
        'userId': 'u1',
        'remoteId': 'r1',
        'time': '08:00',
        'productName': '药A',
      });
      await db.insert('reminders', {
        'userId': 'u1',
        'remoteId': 'r2',
        'time': '20:00',
        'productName': '药B',
      });

      final result = await loadReminderMetaMap(db, 'u1');
      expect(result.length, 2);
      expect(result['r1']!.time, '08:00');
      expect(result['r1']!.title, '药A');
      expect(result['r2']!.time, '20:00');
      expect(result['r2']!.title, '药B');
    });
  });

  group('loadTodayCheckinRecordsFromDb', () {
    test('returns items mapped with takenAt from checkins', () async {
      final db = FakeSqfliteDatabase();
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.insert('checkins', {
        'userId': 'u1',
        'reminderRemoteId': 'rem-a',
        'takenAt': now,
      });

      final items = [
        ReminderItem(
          id: 'rem-a',
          time: '08:00',
          title: '药A',
          subtitle: '',
          dosage: '',
          done: true,
        ),
        ReminderItem(
          id: 'rem-b',
          time: '12:00',
          title: '药B',
          subtitle: '',
          dosage: '',
          done: false,
        ),
      ];

      final result = await loadTodayCheckinRecordsFromDb(
        db: db,
        userId: 'u1',
        startMs: now - 1000,
        endMs: now + 1000,
        todayKey: '2026-05-26',
        items: items,
      );

      expect(result.length, 2);
      expect(result[0].reminderId, 'rem-a');
      expect(result[0].done, isTrue);
      expect(result[0].takenAt, now);
      expect(result[1].reminderId, 'rem-b');
      expect(result[1].done, isFalse);
      expect(result[1].takenAt, isNull);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/models/home.dart';

void main() {
  group('ReminderItem', () {
    const sampleJson = {
      'id': 'rem-001',
      'time': '08:30',
      'title': '阿莫西林',
      'subtitle': '早餐后 1 粒',
      'dosage': '1粒',
      'done': true,
    };

    test('fromJson parses all fields', () {
      final item = ReminderItem.fromJson(sampleJson);

      expect(item.id, 'rem-001');
      expect(item.time, '08:30');
      expect(item.title, '阿莫西林');
      expect(item.subtitle, '早餐后 1 粒');
      expect(item.dosage, '1粒');
      expect(item.done, isTrue);
    });

    test('fromJson handles _id alias', () {
      final json = {
        '_id': 'rem-x',
        'time': '12:00',
        'title': '维生素',
        'subtitle': '',
        'dosage': '',
        'done': false,
      };

      final item = ReminderItem.fromJson(json);
      expect(item.id, 'rem-x');
    });

    test('fromJson handles missing fields', () {
      final item = ReminderItem.fromJson({});

      expect(item.id, '');
      expect(item.time, '');
      expect(item.title, '');
      expect(item.subtitle, '');
      expect(item.dosage, '');
      expect(item.done, isFalse);
    });

    test('fromJson handles various done truthy values', () {
      expect(ReminderItem.fromJson({'done': true}).done, isTrue);
      expect(ReminderItem.fromJson({'done': 1}).done, isTrue);
      expect(ReminderItem.fromJson({'done': 'yes'}).done, isTrue);
      expect(ReminderItem.fromJson({'done': false}).done, isFalse);
      expect(ReminderItem.fromJson({'done': 0}).done, isFalse);
      expect(ReminderItem.fromJson({'done': null}).done, isFalse);
    });

    test('toJson → fromJson round-trip', () {
      const original = ReminderItem(
        id: 'rem-r',
        time: '20:00',
        title: '板蓝根',
        subtitle: '晚饭后',
        dosage: '1袋',
        done: true,
      );

      final json = original.toJson();
      final restored = ReminderItem.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.time, original.time);
      expect(restored.title, original.title);
      expect(restored.subtitle, original.subtitle);
      expect(restored.dosage, original.dosage);
      expect(restored.done, original.done);
    });
  });

  group('HomeFeatureItemData', () {
    test('constructor sets all fields', () {
      const item = HomeFeatureItemData(
        id: 'scan',
        title: '扫码识药',
        subtitle: '拍照识别药品',
        icon: IconData(0xe000),
        color: Color(0xFF0000FF),
      );

      expect(item.id, 'scan');
      expect(item.title, '扫码识药');
      expect(item.subtitle, '拍照识别药品');
    });
  });

  group('HomeCheckInRecordData', () {
    test('constructor sets all fields', () {
      const item = HomeCheckInRecordData(
        dateKey: '2026-05-26',
        reminderId: 'rem-1',
        title: '阿莫西林',
        reminderTime: '08:30',
        done: true,
        takenAt: 1234567890000,
      );

      expect(item.dateKey, '2026-05-26');
      expect(item.reminderId, 'rem-1');
      expect(item.title, '阿莫西林');
      expect(item.reminderTime, '08:30');
      expect(item.done, isTrue);
      expect(item.takenAt, 1234567890000);
    });

    test('takenAt is nullable', () {
      const item = HomeCheckInRecordData(
        dateKey: '2026-05-26',
        reminderId: 'rem-1',
        title: '',
        reminderTime: '',
        done: false,
      );

      expect(item.takenAt, isNull);
    });
  });

  group('TodayRemindersResult', () {
    test('fromJson parses date and items', () {
      final json = {
        'date': '2026-05-26',
        'items': [
          {
            'id': 'r1',
            'time': '08:00',
            'title': '药A',
            'subtitle': '',
            'dosage': '',
            'done': true,
          },
          {
            'id': 'r2',
            'time': '20:00',
            'title': '药B',
            'subtitle': '饭后',
            'dosage': '2粒',
            'done': false,
          },
        ],
      };

      final result = TodayRemindersResult.fromJson(json);
      expect(result.date, '2026-05-26');
      expect(result.items.length, 2);
      expect(result.items[0].id, 'r1');
      expect(result.items[0].done, isTrue);
      expect(result.items[1].id, 'r2');
      expect(result.items[1].dosage, '2粒');
    });

    test('fromJson handles empty items', () {
      final json = {'date': '2026-05-26', 'items': []};
      final result = TodayRemindersResult.fromJson(json);
      expect(result.items, isEmpty);
    });

    test('fromJson handles missing date', () {
      final json = {'items': []};
      final result = TodayRemindersResult.fromJson(json);
      expect(result.date, '');
    });

    test('toJson → fromJson round-trip', () {
      final original = TodayRemindersResult(
        date: '2026-05-26',
        items: [
          ReminderItem.fromJson({
            'id': 'r1',
            'time': '08:00',
            'title': '药A',
            'subtitle': '',
            'dosage': '',
            'done': true,
          }),
        ],
      );

      final json = original.toJson();
      final restored = TodayRemindersResult.fromJson(json);

      expect(restored.date, original.date);
      expect(restored.items.length, original.items.length);
      expect(restored.items[0].id, original.items[0].id);
    });
  });
}

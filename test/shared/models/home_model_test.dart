import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/models/home.dart';

void main() {
  group('ReminderItem JSON round-trip', () {
    test('fromJson → toJson → fromJson preserves fields', () {
      final original = ReminderItem.fromJson(const {
        'id': 'rem-1',
        'time': '08:30',
        'title': '阿莫西林',
        'subtitle': '早餐后 1 粒',
        'dosage': '1 粒',
        'done': false,
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = ReminderItem.fromJson(decoded);

      expect(rebuilt.id, 'rem-1');
      expect(rebuilt.time, '08:30');
      expect(rebuilt.title, '阿莫西林');
      expect(rebuilt.subtitle, '早餐后 1 粒');
      expect(rebuilt.dosage, '1 粒');
      expect(rebuilt.done, false);
    });

    test('fromJson handles _id fallback', () {
      final item = ReminderItem.fromJson(const {'_id': 'alt-1', 'time': '09:00'});

      expect(item.id, 'alt-1');
      expect(item.time, '09:00');
    });

    test('fromJson handles missing keys', () {
      final item = ReminderItem.fromJson(const {});

      expect(item.id, '');
      expect(item.time, '');
      expect(item.done, false);
    });
  });

  group('TodayRemindersResult JSON round-trip', () {
    test('fromJson → toJson → fromJson preserves items', () {
      final original = TodayRemindersResult.fromJson({
        'date': '2026-05-26',
        'items': [
          {'id': 'r1', 'time': '08:30', 'title': '药A', 'subtitle': '', 'done': true},
          {'id': 'r2', 'time': '21:00', 'title': '药B', 'subtitle': '', 'done': false},
        ],
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = TodayRemindersResult.fromJson(decoded);

      expect(rebuilt.date, '2026-05-26');
      expect(rebuilt.items.length, 2);
      expect(rebuilt.items[0].id, 'r1');
      expect(rebuilt.items[1].id, 'r2');
    });

    test('fromJson handles empty items', () {
      final result = TodayRemindersResult.fromJson(const {'date': '2026-01-01'});

      expect(result.date, '2026-01-01');
      expect(result.items, isEmpty);
    });
  });
}

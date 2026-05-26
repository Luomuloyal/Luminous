import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

void main() {
  group('ReminderMedicineRef', () {
    test('fromJson parses all fields', () {
      final item = ReminderMedicineRef.fromJson({
        'drugCode': '8691234567890',
        'approvalNo': '国药准字H20230001',
        'productName': '阿莫西林胶囊',
      });

      expect(item.drugCode, '8691234567890');
      expect(item.approvalNo, '国药准字H20230001');
      expect(item.productName, '阿莫西林胶囊');
    });

    test('fromJson handles missing fields', () {
      final item = ReminderMedicineRef.fromJson({});
      expect(item.drugCode, '');
      expect(item.approvalNo, '');
      expect(item.productName, '');
    });

    test('toJson → fromJson round-trip via jsonEncode', () {
      final original = ReminderMedicineRef.fromJson({
        'drugCode': '8690000000000',
        'approvalNo': '国药准字Z20240001',
        'productName': '板蓝根颗粒',
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = ReminderMedicineRef.fromJson(decoded);

      expect(rebuilt.drugCode, original.drugCode);
      expect(rebuilt.approvalNo, original.approvalNo);
      expect(rebuilt.productName, original.productName);
    });
  });

  group('ReminderPlan', () {
    final sampleJson = <String, dynamic>{
      'id': 'plan-001',
      'userId': 'u123',
      'time': '08:30',
      'drugCode': '8690000000000',
      'approvalNo': '国药准字H20230001',
      'productName': '阿莫西林胶囊',
      'dosage': '1粒',
      'subtitle': '早餐后服用',
      'enabled': true,
      'repeatRule': 'daily',
      'method': 'notification',
      'startDate': '2026-01-01',
      'endDate': '',
    };

    test('fromJson parses all fields', () {
      final plan = ReminderPlan.fromJson(sampleJson);

      expect(plan.id, 'plan-001');
      expect(plan.userId, 'u123');
      expect(plan.time, '08:30');
      expect(plan.drugCode, '8690000000000');
      expect(plan.approvalNo, '国药准字H20230001');
      expect(plan.productName, '阿莫西林胶囊');
      expect(plan.dosage, '1粒');
      expect(plan.subtitle, '早餐后服用');
      expect(plan.enabled, isTrue);
      expect(plan.repeatRule, 'daily');
      expect(plan.method, 'notification');
      expect(plan.startDate, '2026-01-01');
      expect(plan.endDate, '');
    });

    test('fromJson handles _id fallback', () {
      final plan = ReminderPlan.fromJson({
        '_id': 'alt-001',
        'time': '12:00',
      });

      expect(plan.id, 'alt-001');
    });

    test('fromJson handles missing fields with defaults', () {
      final plan = ReminderPlan.fromJson({});

      expect(plan.id, '');
      expect(plan.userId, '');
      expect(plan.time, '');
      expect(plan.productName, '');
      expect(plan.enabled, isTrue);
      expect(plan.repeatRule, 'daily');
      expect(plan.method, 'notification');
    });

    test('fromJson with medicines array overrides legacy fields', () {
      final plan = ReminderPlan.fromJson({
        'id': 'plan-002',
        'time': '20:00',
        'drugCode': 'old-code',
        'approvalNo': 'old-approval',
        'productName': '旧名称',
        'medicines': [
          {
            'drugCode': 'new-code',
            'approvalNo': 'new-approval',
            'productName': '新药品',
          },
        ],
      });

      expect(plan.drugCode, 'old-code');
      expect(plan.approvalNo, 'old-approval');
      // productName 仍取 legacy，因为 legacyProductName 非空时不从 medicines 推导
      expect(plan.productName, '旧名称');
      expect(plan.medicines.length, 1);
      expect(plan.medicines[0].productName, '新药品');
    });

    test('fromJson derives productName from medicines when legacy is empty', () {
      final plan = ReminderPlan.fromJson({
        'id': 'plan-003',
        'time': '08:00',
        'productName': '',
        'medicines': [
          {'drugCode': '', 'approvalNo': '', 'productName': '维生素D'},
          {'drugCode': '', 'approvalNo': '', 'productName': '钙片'},
        ],
      });

      expect(plan.productName, '维生素D、钙片');
    });

    test('toJson → fromJson round-trip via jsonEncode', () {
      final original = ReminderPlan.fromJson(sampleJson);

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = ReminderPlan.fromJson(decoded);

      expect(rebuilt.id, original.id);
      expect(rebuilt.time, original.time);
      expect(rebuilt.productName, original.productName);
      expect(rebuilt.dosage, original.dosage);
      expect(rebuilt.enabled, original.enabled);
      expect(rebuilt.repeatRule, original.repeatRule);
    });

    test('hasId returns false for empty id', () {
      final plan = ReminderPlan.fromJson({});
      expect(plan.hasId, isFalse);
    });

    test('hasId returns true for non-empty id', () {
      final plan = ReminderPlan.fromJson({'id': 'r1'});
      expect(plan.hasId, isTrue);
    });

    test('displayTitle formats time + productName', () {
      final plan = ReminderPlan.fromJson({
        'time': '08:30',
        'productName': '阿莫西林',
      });

      expect(plan.displayTitle, '08:30 阿莫西林');
    });

    test('displayTitle works with empty time', () {
      final plan = ReminderPlan.fromJson({
        'time': '',
        'productName': '阿莫西林',
      });

      expect(plan.displayTitle, '阿莫西林');
    });
  });

  group('ReminderListResult', () {
    test('fromJson parses items', () {
      final json = {
        'items': [
          {
            'id': 'p1',
            'time': '08:00',
            'productName': '药A',
          },
          {
            'id': 'p2',
            'time': '20:00',
            'productName': '药B',
          },
        ],
      };

      final result = ReminderListResult.fromJson(json);
      expect(result.items.length, 2);
      expect(result.items[0].id, 'p1');
      expect(result.items[1].id, 'p2');
    });

    test('fromJson handles empty items', () {
      final result = ReminderListResult.fromJson({'items': []});
      expect(result.items, isEmpty);
    });

    test('fromJson handles missing items key', () {
      final result = ReminderListResult.fromJson({});
      expect(result.items, isEmpty);
    });

    test('toJson → fromJson round-trip via jsonEncode', () {
      final original = ReminderListResult.fromJson({
        'items': [
          {'id': 'r1', 'time': '08:30', 'productName': '药A'},
          {'id': 'r2', 'time': '21:00', 'productName': '药B'},
        ],
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = ReminderListResult.fromJson(decoded);

      expect(rebuilt.items.length, 2);
      expect(rebuilt.items[0].id, 'r1');
      expect(rebuilt.items[1].id, 'r2');
    });
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/models/medicine.dart';

void main() {
  group('MedicineItem JSON round-trip', () {
    test('fromJson → toJson → fromJson produces equal', () {
      final original = MedicineItem.fromJson(const {
        'serialNo': 'S001',
        'approvalNo': 'H12345678',
        'productName': '阿莫西林胶囊',
        'dosageForm': '胶囊剂',
        'specification': '0.25g',
        'marketingAuthorizationHolder': '某某药业',
        'manufacturer': '某某制药厂',
        'drugCode': 'D001',
        'drugCodeRemark': '国药准字',
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = MedicineItem.fromJson(decoded);

      expect(rebuilt.serialNo, original.serialNo);
      expect(rebuilt.approvalNo, original.approvalNo);
      expect(rebuilt.productName, original.productName);
      expect(rebuilt.dosageForm, original.dosageForm);
      expect(rebuilt.specification, original.specification);
      expect(rebuilt.marketingAuthorizationHolder,
          original.marketingAuthorizationHolder);
      expect(rebuilt.manufacturer, original.manufacturer);
      expect(rebuilt.drugCode, original.drugCode);
      expect(rebuilt.drugCodeRemark, original.drugCodeRemark);
    });

    test('fromJson handles missing keys gracefully', () {
      final item = MedicineItem.fromJson(const {});
      expect(item.serialNo, '');
      expect(item.approvalNo, '');
      expect(item.productName, '');
      expect(item.hasIdentity, false);
    });
  });

  group('MedicineSearchResult JSON round-trip', () {
    test('fromJson → toJson → fromJson preserves items', () {
      final original = MedicineSearchResult.fromJson({
        'items': [
          {
            'serialNo': '',
            'approvalNo': 'H001',
            'productName': '布洛芬',
            'dosageForm': '片剂',
            'specification': '0.2g',
            'marketingAuthorizationHolder': '',
            'manufacturer': 'A厂',
            'drugCode': '',
            'drugCodeRemark': '',
          },
        ],
        'total': 1,
        'page': 1,
        'pageSize': 20,
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = MedicineSearchResult.fromJson(decoded);

      expect(rebuilt.items.length, 1);
      expect(rebuilt.items.first.productName, '布洛芬');
      expect(rebuilt.total, 1);
      expect(rebuilt.page, 1);
      expect(rebuilt.pageSize, 20);
      expect(rebuilt.hasMore, false);
    });

    test('fromJson handles empty items', () {
      final result = MedicineSearchResult.fromJson({
        'total': 0,
        'pageSize': 20,
      });

      expect(result.items, isEmpty);
      expect(result.total, 0);
      expect(result.hasMore, false);
    });
  });

  group('MedicineAiDetailResult JSON round-trip', () {
    test('fromJson → toJson → fromJson preserves text and source', () {
      final original = MedicineAiDetailResult.fromJson({
        'text': '阿莫西林为青霉素类抗生素...',
        'source': 'generated',
        'cachedAt': 1609459200000,
        'expiresAt': 1609545600000,
      });

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = MedicineAiDetailResult.fromJson(decoded);

      expect(rebuilt.text, original.text);
      expect(rebuilt.source, 'generated');
      expect(rebuilt.hasText, true);
      expect(rebuilt.isCached, false);
      expect(rebuilt.cachedAt?.millisecondsSinceEpoch, 1609459200000);
    });

    test('fromJson handles cache source', () {
      final result = MedicineAiDetailResult.fromJson({
        'text': '',
        'source': 'cache',
      });

      expect(result.hasText, false);
      expect(result.isCached, true);
      expect(result.cachedAt, isNull);
    });

    test('fromJson handles null timestamps', () {
      final result = MedicineAiDetailResult.fromJson({
        'text': 'test',
      });

      expect(result.cachedAt, isNull);
      expect(result.expiresAt, isNull);
    });
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/mine/presentation/models/browse_history.dart';
import 'package:luminous/shared/models/medicine.dart';

void main() {
  group('BrowseHistoryEntry', () {
    final sampleJson = <String, dynamic>{
      'identityKey': 'drug:8690000000000',
      'productName': '阿莫西林胶囊',
      'dosageForm': '胶囊剂',
      'specification': '0.25g',
      'manufacturer': '某某制药厂',
      'marketingAuthorizationHolder': '某某药业',
      'drugCode': '8690000000000',
      'approvalNo': '国药准字H20230001',
      'viewedAtMillis': 1717171200000,
    };

    test('fromJson parses all fields', () {
      final entry = BrowseHistoryEntry.fromJson(sampleJson);

      expect(entry.identityKey, 'drug:8690000000000');
      expect(entry.productName, '阿莫西林胶囊');
      expect(entry.dosageForm, '胶囊剂');
      expect(entry.specification, '0.25g');
      expect(entry.manufacturer, '某某制药厂');
      expect(entry.marketingAuthorizationHolder, '某某药业');
      expect(entry.drugCode, '8690000000000');
      expect(entry.approvalNo, '国药准字H20230001');
      expect(entry.viewedAtMillis, 1717171200000);
    });

    test('fromJson handles missing fields', () {
      final entry = BrowseHistoryEntry.fromJson({});

      expect(entry.identityKey, '');
      expect(entry.productName, '');
      expect(entry.dosageForm, '');
      expect(entry.specification, '');
      expect(entry.manufacturer, '');
      expect(entry.marketingAuthorizationHolder, '');
      expect(entry.drugCode, '');
      expect(entry.approvalNo, '');
      expect(entry.viewedAtMillis, 0);
    });

    test('fromJson handles non-numeric viewedAtMillis', () {
      final entry = BrowseHistoryEntry.fromJson({
        'viewedAtMillis': 'not-a-number',
      });

      expect(entry.viewedAtMillis, 0);
    });

    test('toJson → fromJson round-trip via jsonEncode', () {
      final original = BrowseHistoryEntry.fromJson(sampleJson);

      final encoded = jsonEncode(original.toJson());
      final decoded = jsonDecode(encoded) as Map<String, dynamic>;
      final rebuilt = BrowseHistoryEntry.fromJson(decoded);

      expect(rebuilt.identityKey, original.identityKey);
      expect(rebuilt.productName, original.productName);
      expect(rebuilt.dosageForm, original.dosageForm);
      expect(rebuilt.specification, original.specification);
      expect(rebuilt.manufacturer, original.manufacturer);
      expect(rebuilt.drugCode, original.drugCode);
      expect(rebuilt.approvalNo, original.approvalNo);
      expect(rebuilt.viewedAtMillis, original.viewedAtMillis);
    });

    test('hasIdentity returns false for empty identityKey', () {
      final entry = BrowseHistoryEntry.fromJson({});
      expect(entry.hasIdentity, isFalse);
    });

    test('hasIdentity returns true for non-empty identityKey', () {
      final entry = BrowseHistoryEntry.fromJson({'identityKey': 'drug:123'});
      expect(entry.hasIdentity, isTrue);
    });

    test('displayTitle falls back when productName is empty', () {
      final entry = BrowseHistoryEntry.fromJson({});
      expect(entry.displayTitle, isNotEmpty);
    });

    test('displayTitle returns productName when non-empty', () {
      final entry = BrowseHistoryEntry.fromJson({'productName': '测试药品'});
      expect(entry.displayTitle, '测试药品');
    });

    test('displaySubtitle returns joined dosageForm + specification', () {
      final entry = BrowseHistoryEntry.fromJson({
        'dosageForm': '片剂',
        'specification': '10mg',
      });

      expect(entry.displaySubtitle, contains('片剂'));
      expect(entry.displaySubtitle, contains('10mg'));
    });

    test('displaySubtitle falls back when both empty', () {
      final entry = BrowseHistoryEntry.fromJson({});
      expect(entry.displaySubtitle, isNotEmpty);
    });

    test('displayTips prioritizes manufacturer', () {
      final entry = BrowseHistoryEntry.fromJson({
        'manufacturer': '厂家A',
        'marketingAuthorizationHolder': '持有方B',
      });

      expect(entry.displayTips, '厂家A');
    });

    test('displayTips falls back to marketingAuthorizationHolder', () {
      final entry = BrowseHistoryEntry.fromJson({
        'manufacturer': '',
        'marketingAuthorizationHolder': '持有方B',
      });

      expect(entry.displayTips, '持有方B');
    });

    test('fromMedicineItem constructs from MedicineItem', () {
      const item = MedicineItem(
        serialNo: '',
        approvalNo: '国药准字H20230001',
        productName: '测试药',
        dosageForm: '片剂',
        specification: '5mg',
        marketingAuthorizationHolder: '',
        manufacturer: '测试厂',
        drugCode: '123456789',
        drugCodeRemark: '',
      );

      final entry = BrowseHistoryEntry.fromMedicineItem(
        item,
        viewedAtMillis: 1000,
      );

      expect(entry.productName, '测试药');
      expect(entry.drugCode, '123456789');
      expect(entry.identityKey, 'drug:123456789');
      expect(entry.viewedAtMillis, 1000);
    });

    test('toMedicineItem round-trips fields', () {
      final entry = BrowseHistoryEntry.fromJson(sampleJson);
      final item = entry.toMedicineItem();

      expect(item.approvalNo, entry.approvalNo);
      expect(item.productName, entry.productName);
      expect(item.dosageForm, entry.dosageForm);
      expect(item.specification, entry.specification);
      expect(item.manufacturer, entry.manufacturer);
      expect(item.drugCode, entry.drugCode);
    });

    test('identityKeyFromMedicine generates drug: prefix', () {
      const item = MedicineItem(
        serialNo: '',
        approvalNo: '',
        productName: '',
        dosageForm: '',
        specification: '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: '8691234567890',
        drugCodeRemark: '',
      );

      expect(
        BrowseHistoryEntry.identityKeyFromMedicine(item),
        'drug:8691234567890',
      );
    });

    test('identityKeyFromMedicine falls back to approval prefix', () {
      const item = MedicineItem(
        serialNo: '',
        approvalNo: 'H20230001',
        productName: '',
        dosageForm: '',
        specification: '',
        marketingAuthorizationHolder: '',
        manufacturer: '',
        drugCode: '',
        drugCodeRemark: '',
      );

      expect(
        BrowseHistoryEntry.identityKeyFromMedicine(item),
        'approval:H20230001',
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/models/medicine.dart';

void main() {
  group('MedicineItem', () {
    const sampleJson = {
      'serialNo': '001',
      'approvalNo': '国药准字H20230001',
      'productName': '阿莫西林胶囊',
      'dosageForm': '胶囊剂',
      'specification': '0.25g',
      'marketingAuthorizationHolder': '某某药业',
      'manufacturer': '某某制药厂',
      'drugCode': '8691234567890',
      'drugCodeRemark': '本位码',
    };

    test('fromJson parses all fields', () {
      final item = MedicineItem.fromJson(sampleJson);

      expect(item.serialNo, '001');
      expect(item.approvalNo, '国药准字H20230001');
      expect(item.productName, '阿莫西林胶囊');
      expect(item.dosageForm, '胶囊剂');
      expect(item.specification, '0.25g');
      expect(item.marketingAuthorizationHolder, '某某药业');
      expect(item.manufacturer, '某某制药厂');
      expect(item.drugCode, '8691234567890');
      expect(item.drugCodeRemark, '本位码');
    });

    test('fromJson handles empty/missing fields', () {
      final item = MedicineItem.fromJson({});

      expect(item.serialNo, '');
      expect(item.approvalNo, '');
      expect(item.productName, '');
      expect(item.dosageForm, '');
      expect(item.specification, '');
      expect(item.marketingAuthorizationHolder, '');
      expect(item.manufacturer, '');
      expect(item.drugCode, '');
      expect(item.drugCodeRemark, '');
    });

    test('toJson → fromJson round-trip', () {
      const original = MedicineItem(
        serialNo: '002',
        approvalNo: '国药准字Z20240001',
        productName: '板蓝根颗粒',
        dosageForm: '颗粒剂',
        specification: '10g×20袋',
        marketingAuthorizationHolder: '测试药业',
        manufacturer: '测试制药',
        drugCode: '6901234567890',
        drugCodeRemark: '',
      );

      final json = original.toJson();
      final restored = MedicineItem.fromJson(json);

      expect(restored.serialNo, original.serialNo);
      expect(restored.approvalNo, original.approvalNo);
      expect(restored.productName, original.productName);
      expect(restored.dosageForm, original.dosageForm);
      expect(restored.specification, original.specification);
      expect(restored.marketingAuthorizationHolder,
          original.marketingAuthorizationHolder);
      expect(restored.manufacturer, original.manufacturer);
      expect(restored.drugCode, original.drugCode);
      expect(restored.drugCodeRemark, original.drugCodeRemark);
    });

    test('computed getters work correctly', () {
      final empty = MedicineItem.fromJson({});
      expect(empty.hasIdentity, isFalse);
      expect(empty.displayName, isNotEmpty);
      expect(empty.displaySubtitle, isNotEmpty);
      expect(empty.displayTips, '');

      final full = MedicineItem.fromJson(sampleJson);
      expect(full.hasIdentity, isTrue);
      expect(full.displayName, '阿莫西林胶囊');
      expect(full.displaySubtitle, contains('胶囊剂'));
      expect(full.displaySubtitle, contains('0.25g'));
      expect(full.displayTips, '某某制药厂');
      expect(full.displayBadge, '胶囊剂');
    });
  });

  group('MedicineSearchResult', () {
    test('fromJson parses items list', () {
      final json = {
        'items': [
          {
            'serialNo': '001',
            'approvalNo': 'H001',
            'productName': '药A',
            'dosageForm': '片剂',
            'specification': '10mg',
            'marketingAuthorizationHolder': '',
            'manufacturer': '厂A',
            'drugCode': '',
            'drugCodeRemark': '',
          },
          {
            'serialNo': '002',
            'approvalNo': 'H002',
            'productName': '药B',
            'dosageForm': '胶囊剂',
            'specification': '20mg',
            'marketingAuthorizationHolder': '',
            'manufacturer': '厂B',
            'drugCode': '',
            'drugCodeRemark': '',
          },
        ],
        'total': '50',
        'page': '1',
        'pageSize': '20',
      };

      final result = MedicineSearchResult.fromJson(json);

      expect(result.items.length, 2);
      expect(result.items[0].productName, '药A');
      expect(result.items[1].productName, '药B');
      expect(result.total, 50);
      expect(result.page, 1);
      expect(result.pageSize, 20);
      expect(result.hasMore, isTrue);
    });

    test('fromJson handles missing total with item count fallback', () {
      final json = {
        'items': [
          {
            'serialNo': '001',
            'approvalNo': 'H001',
            'productName': 'X',
            'dosageForm': '',
            'specification': '',
            'marketingAuthorizationHolder': '',
            'manufacturer': '',
            'drugCode': '',
            'drugCodeRemark': '',
          },
        ],
      };

      final result = MedicineSearchResult.fromJson(json);
      expect(result.total, 1); // falls back to items.length
    });

    test('fromJson handles invalid pageSize fallback', () {
      final json = {
        'items': [],
        'pageSize': 'abc',
      };

      final result = MedicineSearchResult.fromJson(json);
      expect(result.pageSize, 20); // default fallback
    });

    test('toJson → fromJson round-trip', () {
      final original = MedicineSearchResult(
        items: [
          MedicineItem.fromJson({
            'serialNo': '001',
            'approvalNo': 'H001',
            'productName': '药A',
            'dosageForm': '片剂',
            'specification': '',
            'marketingAuthorizationHolder': '',
            'manufacturer': '',
            'drugCode': '',
            'drugCodeRemark': '',
          }),
        ],
        total: 42,
        page: 3,
        pageSize: 10,
      );

      final json = original.toJson();
      final restored = MedicineSearchResult.fromJson(json);

      expect(restored.total, original.total);
      expect(restored.page, original.page);
      expect(restored.pageSize, original.pageSize);
      expect(restored.items.length, original.items.length);
      expect(restored.items[0].productName, original.items[0].productName);
    });
  });

  group('MedicineAiDetailResult', () {
    test('fromJson parses text and source', () {
      final json = {
        'text': '这是AI解读内容',
        'source': 'generated',
      };

      final result = MedicineAiDetailResult.fromJson(json);
      expect(result.text, '这是AI解读内容');
      expect(result.source, 'generated');
      expect(result.hasText, isTrue);
      expect(result.isCached, isFalse);
    });

    test('fromJson handles cache source', () {
      final json = {
        'text': '缓存内容',
        'source': 'cache',
      };

      final result = MedicineAiDetailResult.fromJson(json);
      expect(result.isCached, isTrue);
    });

    test('fromJson handles missing fields', () {
      final result = MedicineAiDetailResult.fromJson({});
      expect(result.text, '');
      expect(result.source, 'generated');
      expect(result.cachedAt, isNull);
      expect(result.expiresAt, isNull);
      expect(result.hasText, isFalse);
    });

    test('fromJson parses timestamps as millis', () {
      final now = DateTime.now();
      final json = {
        'text': 'test',
        'cachedAt': now.millisecondsSinceEpoch,
        'expiresAt': now.add(const Duration(hours: 1)).millisecondsSinceEpoch,
      };

      final result = MedicineAiDetailResult.fromJson(json);
      expect(result.cachedAt?.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
      expect(result.expiresAt, isNotNull);
    });

    test('toJson → fromJson round-trip', () {
      final now = DateTime.now();
      final original = MedicineAiDetailResult(
        text: '往返测试',
        source: 'generated',
        cachedAt: now,
        expiresAt: now.add(const Duration(hours: 2)),
      );

      final json = original.toJson();
      final restored = MedicineAiDetailResult.fromJson(json);

      expect(restored.text, original.text);
      expect(restored.source, original.source);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/mine/data/browse_history_store.dart';
import 'package:luminous/features/mine/presentation/models/browse_history.dart';

void main() {
  group('sameBrowseHistoryEntries', () {
    test('identical references return true', () {
      final list = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:123',
          'productName': '药A',
          'viewedAtMillis': 1000,
        }),
      ];

      expect(sameBrowseHistoryEntries(list, list), isTrue);
    });

    test('empty lists are equal', () {
      expect(sameBrowseHistoryEntries([], []), isTrue);
    });

    test('same content returns true', () {
      final a = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:123',
          'productName': '阿莫西林',
          'dosageForm': '胶囊剂',
          'viewedAtMillis': 1000,
        }),
      ];
      final b = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:123',
          'productName': '阿莫西林',
          'dosageForm': '胶囊剂',
          'viewedAtMillis': 1000,
        }),
      ];

      expect(sameBrowseHistoryEntries(a, b), isTrue);
    });

    test('different length returns false', () {
      final a = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:1',
          'productName': 'A',
          'viewedAtMillis': 1,
        }),
      ];
      final b = <BrowseHistoryEntry>[];

      expect(sameBrowseHistoryEntries(a, b), isFalse);
    });

    test('different content returns false', () {
      final a = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:1',
          'productName': '阿莫西林',
          'viewedAtMillis': 1000,
        }),
      ];
      final b = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:2',
          'productName': '板蓝根',
          'viewedAtMillis': 2000,
        }),
      ];

      expect(sameBrowseHistoryEntries(a, b), isFalse);
    });

    test('different field values return false', () {
      final a = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:1',
          'productName': '阿莫西林',
          'dosageForm': '胶囊剂',
          'viewedAtMillis': 1000,
        }),
      ];
      final b = [
        BrowseHistoryEntry.fromJson({
          'identityKey': 'drug:1',
          'productName': '阿莫西林',
          'dosageForm': '片剂', // different dosage form
          'viewedAtMillis': 1000,
        }),
      ];

      expect(sameBrowseHistoryEntries(a, b), isFalse);
    });

    test('multiple entries in same order returns true', () {
      List<BrowseHistoryEntry> makeList() => [
            BrowseHistoryEntry.fromJson({
              'identityKey': 'drug:1',
              'productName': '药A',
              'viewedAtMillis': 2000,
            }),
            BrowseHistoryEntry.fromJson({
              'identityKey': 'drug:2',
              'productName': '药B',
              'viewedAtMillis': 1000,
            }),
          ];

      expect(sameBrowseHistoryEntries(makeList(), makeList()), isTrue);
    });
  });
}

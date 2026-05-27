import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/checkin/presentation/widgets/checkin_hero_card.dart';
import 'package:luminous/shared/models/home.dart';

void main() {
  group('CheckInHeroCard', () {
    Widget buildCard(List<ReminderItem> items) {
      return MaterialApp(
        home: Scaffold(body: CheckInHeroCard(items: items)),
      );
    }

    testWidgets('shows correct counts with mixed done/undone items', (
      tester,
    ) async {
      const items = [
        ReminderItem(
          id: 'r1',
          time: '08:00',
          title: '药A',
          subtitle: '',
          dosage: '',
          done: true,
        ),
        ReminderItem(
          id: 'r2',
          time: '12:00',
          title: '药B',
          subtitle: '',
          dosage: '',
          done: false,
        ),
        ReminderItem(
          id: 'r3',
          time: '20:00',
          title: '药C',
          subtitle: '',
          dosage: '',
          done: true,
        ),
      ];

      await tester.pumpWidget(buildCard(items));
      await tester.pumpAndSettle();

      expect(find.text('3 条'), findsOneWidget);
      expect(find.text('2 已打卡'), findsOneWidget);
      expect(find.text('1 待完成'), findsOneWidget);
    });

    testWidgets('shows all pending when nothing is done', (tester) async {
      const items = [
        ReminderItem(
          id: 'r1',
          time: '08:00',
          title: '药A',
          subtitle: '',
          dosage: '',
          done: false,
        ),
      ];

      await tester.pumpWidget(buildCard(items));
      await tester.pumpAndSettle();

      expect(find.text('1 条'), findsOneWidget);
      expect(find.text('0 已打卡'), findsOneWidget);
      expect(find.text('1 待完成'), findsOneWidget);
    });
  });
}

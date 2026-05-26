import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/checkin/presentation/widgets/checkin_item_card.dart';
import 'package:luminous/shared/models/home.dart';

void main() {
  group('CheckInItemCard', () {
    Widget buildCard({required ReminderItem item, VoidCallback? onCheckIn}) {
      return MaterialApp(
        home: Scaffold(
          body: CheckInItemCard(
            item: item,
            onCheckIn: onCheckIn ?? () {},
          ),
        ),
      );
    }

    const undoneItem = ReminderItem(
      id: 'rem-1',
      time: '08:30',
      title: '阿莫西林',
      subtitle: '早餐后 1 粒',
      dosage: '1粒',
      done: false,
    );

    const doneItem = ReminderItem(
      id: 'rem-2',
      time: '20:00',
      title: '维生素D',
      subtitle: '晚饭后 1 粒',
      dosage: '',
      done: true,
    );

    testWidgets('renders undone state with 打卡 button', (tester) async {
      await tester.pumpWidget(buildCard(item: undoneItem));
      await tester.pumpAndSettle();

      expect(find.text('阿莫西林'), findsOneWidget);
      expect(find.text('早餐后 1 粒'), findsOneWidget);
      expect(find.text('1粒'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '打卡'), findsOneWidget);
    });

    testWidgets('renders done state with 取消打卡 button', (tester) async {
      await tester.pumpWidget(buildCard(item: doneItem));
      await tester.pumpAndSettle();

      expect(find.text('维生素D'), findsOneWidget);
      expect(find.text('晚饭后 1 粒'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '取消打卡'), findsOneWidget);
    });

    testWidgets('calls onCheckIn when button is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildCard(
          item: undoneItem,
          onCheckIn: () => tapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, '打卡'));
      expect(tapped, isTrue);
    });

    testWidgets('renders fallback title when title is empty', (tester) async {
      const emptyTitleItem = ReminderItem(
        id: 'rem-3',
        time: '12:00',
        title: '',
        subtitle: '',
        dosage: '',
        done: false,
      );

      await tester.pumpWidget(buildCard(item: emptyTitleItem));
      await tester.pumpAndSettle();

      expect(find.text('用药提醒'), findsOneWidget);
    });
  });
}

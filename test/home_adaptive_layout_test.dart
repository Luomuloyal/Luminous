import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/features/home/presentation/home.dart';
import 'package:luminous/shared/layout/adaptive_layout.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';
import 'support/session_test_utils.dart';

void main() {
  group('HomePage adaptive layout', () {
    late FakeReminderLocalGateway gateway;

    setUp(() {
      Get.testMode = true;
      Get.reset();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      gateway = FakeReminderLocalGateway();
      addTearDown(gateway.dispose);
      addTearDown(Get.reset);
    });

    Future<void> pumpHomeAt(
      WidgetTester tester,
      double width, {
      double height = 800,
    }) async {
      final container = await createTestProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: width,
                height: height,
                child: HomePage(reminderGateway: gateway),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
    }

    testWidgets('renders without overflow at compact width (393px)', (
      tester,
    ) async {
      await pumpHomeAt(tester, 393);

      // Compact should not crash and should show the basic sections.
      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow at medium width (768px)', (
      tester,
    ) async {
      await pumpHomeAt(tester, 768);

      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Medium width should still see expected content but constrained.
      final centerFinder = find.byType(Center);
      expect(centerFinder, findsWidgets);
    });

    testWidgets('renders without overflow at webExpanded width (1280px)', (
      tester,
    ) async {
      await pumpHomeAt(tester, 1280);

      expect(find.byType(HomePage), findsOneWidget);
      expect(tester.takeException(), isNull);

      // WebExpanded width should use Center for constraining.
      final constrainedFinder = find.byType(ConstrainedBox);
      expect(constrainedFinder, findsWidgets);
    });

    test('AppContentWidths returns null for compact, values for others', () {
      expect(AppContentWidths.fromWindowClass(AppWindowClass.compact), isNull);
      expect(AppContentWidths.fromWindowClass(AppWindowClass.medium), 640);
      expect(AppContentWidths.fromWindowClass(AppWindowClass.expanded), 800);
      expect(AppContentWidths.fromWindowClass(AppWindowClass.webExpanded), 840);
    });
  });
}

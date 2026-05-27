import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:luminous/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Smoke', () {
    testWidgets('launches and renders MaterialApp', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('main page renders navigation elements', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('navigates to each tab without crashing', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4 tabs: 主页, 药品, 相册, 我的
      // Bottom nav uses custom image assets, locate by text labels
      expect(find.text('主页'), findsOneWidget);
      expect(find.text('药品'), findsOneWidget);
      expect(find.text('相册'), findsOneWidget);
      expect(find.text('我的'), findsOneWidget);

      // Tap 药品 tab
      await tester.tap(find.text('药品'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Tap 相册 tab
      await tester.tap(find.text('相册'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Tap 我的 tab
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Back to 主页
      await tester.tap(find.text('主页'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('mine tab shows login entry for unauthenticated user', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to 我的 tab by text label
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should render login-related UI
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('navigate from mine tab to login page', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to 我的 tab
      await tester.tap(find.text('我的'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap the login button if visible
      final loginButtons = find.byType(FilledButton);
      if (loginButtons.evaluate().isNotEmpty) {
        await tester.tap(loginButtons.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // Should still have a navigable UI (no crash)
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

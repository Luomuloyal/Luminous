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

      // Home tab (index 0) — already visible
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);

      // Drug tab (index 1)
      await tester.tap(find.byIcon(Icons.medication_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Reminders tab (index 2)
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Safety tab (index 3)
      await tester.tap(find.byIcon(Icons.health_and_safety_outlined));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Mine tab (index 4)
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('login page renders form fields', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to Mine tab
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify login-related UI renders
      expect(find.byType(TextFormField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });
}

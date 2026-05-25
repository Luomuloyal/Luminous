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

      // The app shell should render
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('main page renders navigation elements', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Bottom navigation bar should be present on compact width
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}

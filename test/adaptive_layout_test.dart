import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/shared/layout/adaptive_layout.dart';

void main() {
  test('app window class maps global breakpoints', () {
    expect(AppWindowClass.fromWidth(393), AppWindowClass.compact);
    expect(AppWindowClass.fromWidth(600), AppWindowClass.medium);
    expect(AppWindowClass.fromWidth(839), AppWindowClass.medium);
    expect(AppWindowClass.fromWidth(840), AppWindowClass.expanded);
    expect(AppWindowClass.fromWidth(1199), AppWindowClass.expanded);
    expect(AppWindowClass.fromWidth(1200), AppWindowClass.webExpanded);
  });

  testWidgets('adaptive scaffold switches navigation by window class', (
    tester,
  ) async {
    Widget buildShell(AppWindowClass windowClass) {
      return MaterialApp(
        home: AppAdaptiveScaffold(
          windowClass: windowClass,
          backgroundColor: Colors.white,
          compactBottomNavigationBar: const Text('compact-bottom-nav'),
          wideNavigationPane: const Text('wide-navigation-pane'),
          body: const Text('body'),
        ),
      );
    }

    await tester.pumpWidget(buildShell(AppWindowClass.compact));
    expect(find.text('body'), findsOneWidget);
    expect(find.text('compact-bottom-nav'), findsOneWidget);
    expect(find.text('wide-navigation-pane'), findsNothing);

    await tester.pumpWidget(buildShell(AppWindowClass.expanded));
    expect(find.text('body'), findsOneWidget);
    expect(find.text('compact-bottom-nav'), findsNothing);
    expect(find.text('wide-navigation-pane'), findsOneWidget);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/app.dart';

void main() {
  testWidgets('App should render', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: LuminousApp()));
    expect(find.byType(LuminousApp), findsOneWidget);
  });
}

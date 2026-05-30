import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/app/app.dart';

void main() {
  testWidgets('App should render', (tester) async {
    await tester.pumpWidget(const LuminousApp());
    expect(find.text('今日'), findsOneWidget);
  });
}

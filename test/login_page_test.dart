import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/pages/Login/login.dart';

void main() {
  Widget createWidget() {
    return const MaterialApp(home: LoginPage());
  }

  testWidgets('tap login with empty fields shows phone error', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请输入手机号'), findsWidgets);
  });

  testWidgets('valid form without agreement shows agreement toast', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '13800138000');
    await tester.enterText(fields.at(1), 'Abc123');

    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请先阅读并勾选《用户协议》《隐私政策》'), findsOneWidget);
  });

  testWidgets('valid form with agreement shows success toast', (tester) async {
    await tester.pumpWidget(createWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '13800138000');
    await tester.enterText(fields.at(1), 'Abc123');
    await tester.tap(find.byType(Checkbox));
    await tester.pump();

    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('登录成功'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Login/login.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    final controller = Get.put(UserController(), permanent: true);
    await controller.init();
  });

  Widget createWidget() {
    return const MaterialApp(home: LoginPage());
  }

  testWidgets('tap login with empty fields shows email error', (tester) async {
    await tester.pumpWidget(createWidget());

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请输入邮箱'), findsWidgets);
  });

  testWidgets('valid form without agreement shows agreement toast', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@example.com');
    await tester.enterText(fields.at(1), 'Abc123');

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('请先阅读并勾选《用户协议》《隐私政策》'), findsOneWidget);
  });

  testWidgets('invalid email shows email format error before network', (
    tester,
  ) async {
    await tester.pumpWidget(createWidget());

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@');
    await tester.enterText(fields.at(1), 'Abc123');

    await tester.ensureVisible(find.text('登录'));
    await tester.tap(find.text('登录'));
    await tester.pump();

    expect(find.text('邮箱格式不正确'), findsWidgets);
  });
}

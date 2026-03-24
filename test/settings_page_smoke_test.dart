import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Settings/settings.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final userController = Get.put(UserController(), permanent: true);
    await userController.init();
    final themeController = Get.put(ThemeController(), permanent: true);
    await themeController.init();
  });

  testWidgets('settings page builds without exceptions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('设置'), findsOneWidget);
    expect(find.text('主题模式'), findsOneWidget);
    expect(find.text('主题风格'), findsOneWidget);
  });
}

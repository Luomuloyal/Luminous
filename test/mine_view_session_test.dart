import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/pages/Mine/mine.dart';
import 'package:luminous/stores/providers/shared_preferences_provider.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  testWidgets('mine profile card reads current user from session provider', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final userController = Get.put(UserController(), permanent: true);
    userController.sessionReady.value = true;

    const user = UserSafe(
      id: 'user-1',
      username: 'provider-user',
      email: 'provider@example.com',
      phone: '',
      name: 'Provider User',
      type: 0,
    );
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    await container.read(userSessionProvider.notifier).setUser(user);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: MineView())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Provider User'), findsOneWidget);
  });
}

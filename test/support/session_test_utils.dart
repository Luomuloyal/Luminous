import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> createTestProviderContainer({UserSafe? user}) async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  setGlobalProviderContainer(container);
  addTearDown(() {
    resetGlobalProviderContainerForTest();
    container.dispose();
  });

  if (user != null) {
    await container.read(userSessionProvider.notifier).setUser(user);
  }

  return container;
}

Future<void> setTestSessionUser(UserSafe user) async {
  await globalProviderContainer
      .read(userSessionProvider.notifier)
      .setUser(user);
}

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/stores/providers/shared_preferences_provider.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const user = UserSafe(
    id: 'user-1',
    username: 'tester',
    email: 'tester@example.com',
    phone: '13800138000',
    name: 'Tester',
    type: 0,
  );

  test('user session provider restores persisted user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      GlobalConstants.USER_KEY: jsonEncode(user.toJson()),
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final restoredUser = await container
        .read(userSessionProvider.notifier)
        .restore();

    expect(restoredUser?.id, 'user-1');
    expect(container.read(userSessionProvider).ready, isTrue);
    expect(container.read(userSessionProvider).isLoggedIn, isTrue);
  });

  test('user session provider clears corrupted persisted user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      GlobalConstants.USER_KEY: '{broken-json',
    });
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final restoredUser = await container
        .read(userSessionProvider.notifier)
        .restore();

    expect(restoredUser, isNull);
    expect(container.read(userSessionProvider).isLoggedIn, isFalse);
    expect(prefs.getString(GlobalConstants.USER_KEY), isNull);
  });

  test('user session provider persists and clears current user', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(userSessionProvider.notifier);
    await notifier.setUser(user);

    expect(container.read(userSessionProvider).user?.id, 'user-1');
    expect(prefs.getString(GlobalConstants.USER_KEY), isNotNull);

    await notifier.clear();

    expect(container.read(userSessionProvider).user, isNull);
    expect(prefs.getString(GlobalConstants.USER_KEY), isNull);
  });
}

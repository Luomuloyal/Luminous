import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/features/auth/data/user_session_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const user = UserSafe(
    id: 'user-1',
    username: 'tester',
    email: '',
    phone: '13800138000',
    name: '',
    type: 0,
  );

  test(
    'user controller restores session through feature session store',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        GlobalConstants.USER_KEY: jsonEncode(user.toJson()),
      });
      final prefs = await SharedPreferences.getInstance();
      final controller = UserController(
        sessionStore: UserSessionStore.fromPreferences(prefs),
      );

      controller.markSessionPending();
      await controller.init();

      expect(controller.user.value?.id, 'user-1');
      expect(controller.sessionReady.value, isTrue);
      expect(controller.isLoggedIn, isTrue);
    },
  );

  test(
    'user controller treats corrupted persisted session as logged out',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        GlobalConstants.USER_KEY: 'not-json',
      });
      final prefs = await SharedPreferences.getInstance();
      final controller = UserController(
        sessionStore: UserSessionStore.fromPreferences(prefs),
      );

      controller.markSessionPending();
      await controller.init();

      expect(controller.user.value, isNull);
      expect(controller.sessionReady.value, isTrue);
      expect(prefs.getString(GlobalConstants.USER_KEY), isNull);
    },
  );
}

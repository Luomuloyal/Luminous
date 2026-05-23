import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startup warmup reschedules local reminders before cloud sync', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      GlobalConstants.USER_KEY: jsonEncode(
        const UserSafe(
          id: 'user-1',
          username: 'tester',
          email: '',
          phone: '13800138000',
          name: '',
          type: 0,
        ).toJson(),
      ),
    });

    final calls = <String>[];
    final gateway = FakeReminderLocalGateway()
      ..onRescheduleFromLocal = (userId) async {
        calls.add('reschedule:$userId');
      };

    final controller = UserController();
    final warmup = AppStartupWarmup(
      userController: controller,
      restoreUserSession: () async {
        controller.user.value = const UserSafe(
          id: 'user-1',
          username: 'tester',
          email: '',
          phone: '',
          name: '',
          type: 0,
        );
      },
      warmOrnaments: () async {},
      reminderGateway: gateway,
      syncSession: (userId) async {
        calls.add('sync:$userId');
      },
    );

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    warmup.start();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 320));

    expect(calls, containsAllInOrder(['reschedule:user-1', 'sync:user-1']));
  });
}

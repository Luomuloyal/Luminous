import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/startup/app_startup_warmup.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';
import 'support/session_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startup warmup reschedules local reminders before cloud sync', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await createTestProviderContainer();

    final calls = <String>[];
    final gateway = FakeReminderLocalGateway()
      ..onRescheduleFromLocal = (userId) async {
        calls.add('reschedule:$userId');
      };
    final warmup = AppStartupWarmup(
      restoreUserSession: () async {
        await setTestSessionUser(
          const UserSafe(
            id: 'user-1',
            username: 'tester',
            email: '',
            phone: '',
            name: '',
            type: 0,
          ),
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/features/home/presentation/home.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';
import 'support/session_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    await createTestProviderContainer(
      user: const UserSafe(
        id: 'user-1',
        username: 'tester',
        email: '',
        phone: '13800138000',
        name: '',
        type: 0,
      ),
    );
  });

  tearDown(() {
    ToastUtils.instance.dismiss();
    Get.reset();
  });

  testWidgets('home replaces stale local snapshot after gateway sync', (
    tester,
  ) async {
    final gateway = FakeReminderLocalGateway();
    gateway.setTodayItems('user-1', const [
      ReminderItem(
        id: 'stale-reminder',
        time: '07:30',
        title: '旧本地提醒',
        subtitle: '旧缓存',
        done: false,
      ),
    ]);
    gateway.onSyncRemoteToLocal = (userId) async {
      gateway.setTodayItems(userId, const [
        ReminderItem(
          id: 'remote-reminder',
          time: '09:00',
          title: '远端新提醒',
          subtitle: '以快照为准',
          done: false,
        ),
      ]);
      gateway.emitRevision(userId);
    };

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HomePage(reminderGateway: gateway)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('远端新提醒', findRichText: true), findsWidgets);
    expect(find.textContaining('旧本地提醒', findRichText: true), findsNothing);
    expect(gateway.syncRemoteToLocalCalls, 1);
  });

  test(
    'home clears stale reminders when switched user has no local data',
    () async {
      final gateway = FakeReminderLocalGateway();
      gateway.setTodayItems('user-1', const [
        ReminderItem(
          id: 'remote-reminder',
          time: '09:00',
          title: '旧账号提醒',
          subtitle: '来自 user-1',
          done: false,
        ),
      ]);

      final controller = HomeController(reminderGateway: gateway)
        ..applyLocalizedData(
          healthTips: const ['tip'],
          demoReminders: const <HomeReminderItemData>[],
          demoCheckInRecords: const <HomeCheckInRecordData>[],
        )
        ..onInit();
      addTearDown(controller.onClose);

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.reminders.map((item) => item.title), ['09:00 旧账号提醒']);

      await setTestSessionUser(
        const UserSafe(
          id: 'user-2',
          username: 'tester-2',
          email: '',
          phone: '13900139000',
          name: '',
          type: 0,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(controller.reminders, isEmpty);
    },
  );
}

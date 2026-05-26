import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/reminders/presentation/reminders.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';
import 'support/session_test_utils.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await createTestProviderContainer();
  });

  tearDown(() {});

  test('empty reminder list stays empty instead of seeding defaults', () async {
    await setTestSessionUser(
      const UserSafe(
        id: 'user-empty',
        username: 'tester',
        email: '',
        phone: '13800138000',
        name: '',
        type: 0,
      ),
    );

    final gateway = FakeReminderLocalGateway();
    final controller = ReminderListController(reminderGateway: gateway);

    controller.onInit();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(controller.items, isEmpty);
    expect(controller.error, isNull);
    expect(gateway.syncRemoteToLocalCalls, 1);

    controller.onClose();
  });

  test(
    'reminder list controller reloads from local gateway after revision',
    () async {
      await setTestSessionUser(
        const UserSafe(
          id: 'user-1',
          username: 'tester',
          email: '',
          phone: '13800138000',
          name: '',
          type: 0,
        ),
      );

      final gateway = FakeReminderLocalGateway();
      gateway.setPlans('user-1', const [
        ReminderPlan(
          id: 'rem-1',
          userId: 'user-1',
          time: '08:30',
          drugCode: '',
          approvalNo: '',
          productName: '阿莫西林',
          subtitle: '早餐后 1 粒',
          enabled: true,
          repeatRule: 'daily',
          method: 'notification',
        ),
      ]);

      final controller = ReminderListController(reminderGateway: gateway);

      controller.onInit();
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(controller.items.map((item) => item.id), ['rem-1']);
      final initialLoadCalls = gateway.loadPlansCalls;

      gateway.setPlans('user-1', const [
        ReminderPlan(
          id: 'rem-2',
          userId: 'user-1',
          time: '21:00',
          drugCode: '',
          approvalNo: '',
          productName: '维生素D',
          subtitle: '晚饭后 1 粒',
          enabled: true,
          repeatRule: 'daily',
          method: 'notification',
        ),
      ]);
      gateway.emitRevision('user-1');

      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(gateway.loadPlansCalls, greaterThan(initialLoadCalls));
      expect(controller.items.map((item) => item.id), ['rem-2']);

      controller.onClose();
    },
  );
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/presentation/providers/reminder_list_provider.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('empty reminder list stays empty instead of seeding defaults', () async {
    final prefs = await SharedPreferences.getInstance();
    final gateway = FakeReminderLocalGateway();

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reminderListGatewayProvider.overrideWithValue(gateway),
      ],
    );

    // Set up user
    await container
        .read(userSessionProvider.notifier)
        .setUser(const UserSafe(
          id: 'user-empty',
          username: 'tester',
          email: '',
          phone: '13800138000',
          name: '',
          type: 0,
        ));

    final notifier = container.read(reminderListProvider.notifier);
    await notifier.load();
    await Future.delayed(Duration.zero);
    await Future.delayed(const Duration(milliseconds: 20));

    expect(notifier.state.items, isEmpty);
    expect(notifier.state.error, isNull);
    expect(gateway.syncRemoteToLocalCalls, 1);

    container.dispose();
  });

  test('reminder list reloads from local gateway after revision', () async {
    final prefs = await SharedPreferences.getInstance();
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

    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        reminderListGatewayProvider.overrideWithValue(gateway),
      ],
    );

    await container
        .read(userSessionProvider.notifier)
        .setUser(const UserSafe(
          id: 'user-1',
          username: 'tester',
          email: '',
          phone: '13800138000',
          name: '',
          type: 0,
        ));

    final notifier = container.read(reminderListProvider.notifier);
    await notifier.load();
    await Future.delayed(Duration.zero);
    await Future.delayed(Duration.zero);

    expect(notifier.state.items.map((item) => item.id), ['rem-1']);
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

    await Future.delayed(Duration.zero);
    await Future.delayed(const Duration(milliseconds: 20));

    expect(gateway.loadPlansCalls, greaterThan(initialLoadCalls));
    expect(notifier.state.items.map((item) => item.id), ['rem-2']);

    container.dispose();
  });
}

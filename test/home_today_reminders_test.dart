import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/home/presentation/home.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    ToastUtils.instance.dismiss();
  });

  testWidgets('home replaces stale local snapshot after gateway sync', (
    tester,
  ) async {
    final gateway = FakeReminderLocalGateway();
    addTearDown(gateway.dispose);

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

    // 手动构建 container，在顶层覆盖 gateway
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        homeReminderGatewayProvider.overrideWithValue(gateway),
      ],
    );
    setGlobalProviderContainer(container);
    addTearDown(() {
      resetGlobalProviderContainerForTest();
      container.dispose();
    });

    // 设置用户会话
    await container.read(userSessionProvider.notifier).setUser(
      const UserSafe(
        id: 'user-1',
        username: 'tester',
        email: '',
        phone: '13800138000',
        name: '',
        type: 0,
      ),
    );

    // 启动 HomeNotifier
    container.read(homeProvider.notifier).start();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: HomePage()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(gateway.syncRemoteToLocalCalls, greaterThanOrEqualTo(1));
    expect(find.textContaining('远端新提醒', findRichText: true), findsWidgets);
    expect(find.textContaining('旧本地提醒', findRichText: true), findsNothing);
  });
}

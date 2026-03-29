import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Home/home.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_today_reminder_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();

    final controller = Get.put(UserController(), permanent: true);
    controller.user.value = const UserSafe(
      id: 'user-1',
      username: 'tester',
      email: '',
      phone: '13800138000',
      name: '',
      type: 0,
    );
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'home replaces stale local snapshot with fresh today-reminders result',
    (tester) async {
      final store = FakeTodayReminderStore(
        initialSnapshot: const [
          ReminderItem(
            id: 'stale-reminder',
            time: '07:30',
            title: '旧本地提醒',
            subtitle: '旧缓存',
            done: false,
          ),
        ],
      );

      Future<ApiResult<TodayRemindersResult>> fakeFetch({
        String? userId,
      }) async {
        return const ApiResult<TodayRemindersResult>(
          code: '1',
          msg: 'ok',
          result: TodayRemindersResult(
            date: '',
            items: [
              ReminderItem(
                id: 'remote-reminder',
                time: '09:00',
                title: '远端新提醒',
                subtitle: '以快照为准',
                done: false,
              ),
            ],
          ),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeView(
              fetchTodayReminders: fakeFetch,
              todayReminderStore: store,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('远端新提醒', findRichText: true), findsWidgets);
      expect(find.textContaining('旧本地提醒', findRichText: true), findsNothing);
      expect(store.replaceTodaySnapshotCalls, 1);
      expect(store.snapshot.map((item) => item.id), ['remote-reminder']);
    },
  );

  testWidgets(
    'home clears stale reminders when user changes and the new request has no snapshot fallback',
    (tester) async {
      final controller = Get.find<UserController>();
      final store = FakeTodayReminderStore();

      Future<ApiResult<TodayRemindersResult>> fakeFetch({
        String? userId,
      }) async {
        if (userId == 'user-1') {
          return const ApiResult<TodayRemindersResult>(
            code: '1',
            msg: 'ok',
            result: TodayRemindersResult(
              date: '',
              items: [
                ReminderItem(
                  id: 'remote-reminder',
                  time: '09:00',
                  title: '旧账号提醒',
                  subtitle: '来自 user-1',
                  done: false,
                ),
              ],
            ),
          );
        }
        throw const ApiException('network failed');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HomeView(
              fetchTodayReminders: fakeFetch,
              todayReminderStore: store,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('旧账号提醒', findRichText: true), findsWidgets);

      await store.replaceTodaySnapshot(userId: 'user-1', items: const []);
      controller.user.value = const UserSafe(
        id: 'user-2',
        username: 'tester-2',
        email: '',
        phone: '13900139000',
        name: '',
        type: 0,
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('旧账号提醒', findRichText: true), findsNothing);
      expect(find.textContaining('19:30', findRichText: true), findsWidgets);

      ToastUtils.instance.dismiss();
      await tester.pump();
    },
  );
}

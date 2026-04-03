import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/CheckIn/checkin.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:luminous/viewmodels/reminder.dart';
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
    ToastUtils.instance.dismiss();
    Get.reset();
  });

  testWidgets(
    'checkin page builds items from local reminder plans and applies local done state',
    (tester) async {
      final store = FakeTodayReminderStore(initialDoneIds: const {'rem-1'});

      Future<List<ReminderPlan>> loadPlans(String userId) async {
        return const [
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
          ReminderPlan(
            id: 'rem-2',
            userId: 'user-1',
            time: '20:00',
            drugCode: '',
            approvalNo: '',
            productName: '维生素D',
            subtitle: '晚饭后 1 粒',
            enabled: true,
            repeatRule: 'daily',
            method: 'notification',
          ),
          ReminderPlan(
            id: 'rem-3',
            userId: 'user-1',
            time: '22:00',
            drugCode: '',
            approvalNo: '',
            productName: '不会显示',
            subtitle: '已禁用',
            enabled: false,
            repeatRule: 'daily',
            method: 'notification',
          ),
        ];
      }

      await tester.pumpWidget(
        MaterialApp(
          home: CheckInPage(
            loadLocalPlans: loadPlans,
            todayReminderStore: store,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('阿莫西林'), findsOneWidget);
      expect(find.text('维生素D'), findsOneWidget);
      expect(find.text('08:30'), findsOneWidget);
      expect(find.text('20:00'), findsOneWidget);
      expect(find.text('不会显示'), findsNothing);
      expect(find.widgetWithText(FilledButton, '取消打卡'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, '打卡'), findsOneWidget);
    },
  );

  testWidgets('undo checkin shows local-only warning and writes override', (
    tester,
  ) async {
    final store = FakeTodayReminderStore(initialDoneIds: const {'rem-1'});

    Future<List<ReminderPlan>> loadPlans(String userId) async {
      return const [
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
      ];
    }

    await tester.pumpWidget(
      MaterialApp(
        home: CheckInPage(loadLocalPlans: loadPlans, todayReminderStore: store),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '取消打卡'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '取消打卡'));
    await tester.pumpAndSettle();

    expect(find.text('当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '撤销本地打卡'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.widgetWithText(FilledButton, '打卡'), findsOneWidget);
    expect(store.deletedReminderIds, contains('rem-1'));
    expect(store.savedOverrides['rem-1'], isFalse);

    ToastUtils.instance.dismiss();
    await tester.pump();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/checkin/presentation/checkin.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_reminder_local_gateway.dart';
import 'support/session_test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    container = await createTestProviderContainer(
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

  Widget createCheckInWidget(FakeReminderLocalGateway gateway) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(home: CheckInPage(reminderGateway: gateway)),
    );
  }

  tearDown(() {
    ToastUtils.instance.dismiss();
  });

  testWidgets('checkin page renders local today snapshot items', (
    tester,
  ) async {
    final gateway = FakeReminderLocalGateway();
    gateway.setTodayItems('user-1', const [
      ReminderItem(
        id: 'rem-1',
        time: '08:30',
        title: '阿莫西林',
        subtitle: '早餐后 1 粒',
        done: true,
      ),
      ReminderItem(
        id: 'rem-2',
        time: '20:00',
        title: '维生素D',
        subtitle: '晚饭后 1 粒',
        done: false,
      ),
    ]);

    await tester.pumpWidget(createCheckInWidget(gateway));
    await tester.pumpAndSettle();

    expect(find.text('阿莫西林'), findsOneWidget);
    expect(find.text('维生素D'), findsOneWidget);
    expect(find.text('08:30'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '取消打卡'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '打卡'), findsOneWidget);
  });

  testWidgets('undo checkin writes local gateway change and refreshes ui', (
    tester,
  ) async {
    final gateway = FakeReminderLocalGateway();
    gateway.setTodayItems('user-1', const [
      ReminderItem(
        id: 'rem-1',
        time: '08:30',
        title: '阿莫西林',
        subtitle: '早餐后 1 粒',
        done: true,
      ),
    ]);

    await tester.pumpWidget(createCheckInWidget(gateway));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(FilledButton, '取消打卡'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '取消打卡'));
    await tester.pumpAndSettle();

    expect(find.text('当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '撤销本地打卡'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    expect(find.widgetWithText(FilledButton, '打卡'), findsOneWidget);
    ToastUtils.instance.dismiss();
    await tester.pump();
  });
}

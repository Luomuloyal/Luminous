import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:luminous/pages/Reminders/reminder_edit.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/viewmodels/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    Get.testMode = true;
    Get.reset();
    final controller = Get.put(UserController(), permanent: true);
    controller.sessionReady.value = true;
  });

  testWidgets('editing dosage and extra content keeps linked identity', (
    tester,
  ) async {
    const initialPlan = ReminderPlan(
      id: 'reminder-1',
      userId: 'user-1',
      time: '08:00',
      drugCode: 'drug-001',
      approvalNo: 'H123456',
      productName: '阿莫西林',
      subtitle: '早餐后服用 1 粒',
      enabled: true,
      repeatRule: 'daily',
      method: 'notification',
    );

    await tester.pumpWidget(
      const MaterialApp(home: ReminderEditPage(initial: initialPlan)),
    );

    expect(find.textContaining('Drug Code: drug-001'), findsOneWidget);
    expect(find.textContaining('Approval No.: H123456'), findsOneWidget);

    expect(find.textContaining('Drug Code: drug-001'), findsOneWidget);
    expect(find.textContaining('Approval No.: H123456'), findsOneWidget);
  });
}

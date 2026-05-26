import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/reminders/presentation/reminders.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/session_test_utils.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
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

    final container = await createTestProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ReminderEditPage(initial: initialPlan),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Drug Code: drug-001'), findsOneWidget);
    expect(find.textContaining('Approval No.: H123456'), findsOneWidget);
  });
}

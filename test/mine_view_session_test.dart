import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/features/mine/presentation/mine.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/session_test_utils.dart';

void main() {
  setUp(() {
  });

  testWidgets('mine profile card reads current user from session provider', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    const user = UserSafe(
      id: 'user-1',
      username: 'provider-user',
      email: 'provider@example.com',
      phone: '',
      name: 'Provider User',
      type: 0,
    );
    final container = await createTestProviderContainer(user: user);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: MinePage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Provider User'), findsOneWidget);
  });
}

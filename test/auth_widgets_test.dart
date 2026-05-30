import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/theme/app_theme.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';

void main() {
  testWidgets('AuthCodeFieldRow keeps input and button at the same height', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: AuthCodeFieldRow(
                controller: controller,
                label: 'Code',
                buttonLabel: 'Send code',
                onSendCode: () {},
              ),
            ),
          ),
        ),
      ),
    );

    final inputSize = tester.getSize(
      find.byKey(const ValueKey('auth-code-field-input')),
    );
    final buttonSize = tester.getSize(
      find.byKey(const ValueKey('auth-code-field-button')),
    );

    expect(inputSize.height, 56);
    expect(buttonSize.height, 56);
    expect(inputSize.height, buttonSize.height);
  });

  testWidgets('Auth code loading does not make submit button spin', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthCodeFieldRow(
                    controller: controller,
                    label: 'Code',
                    buttonLabel: 'Send code',
                    isLoading: true,
                    onSendCode: () {},
                  ),
                  const SizedBox(height: 12),
                  AuthPrimaryButton(
                    label: 'Submit',
                    isLoading: false,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });
}

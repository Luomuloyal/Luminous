import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/password_reset_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(passwordResetProvider);
    final notifier = ref.read(passwordResetProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final success = state.successMessage?.isNotEmpty == true
        ? state.successMessage
        : null;

    return AuthShell(
      badge: l10n?.authForgotPasswordBadge ?? 'AUTH / RESET',
      title: l10n?.authForgotPasswordTitle ?? 'Reset password from your email.',
      description:
          l10n?.authForgotPasswordDescription ??
          'Send a verification code, set a new password, then return to sign in.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthFormHeader(
            title: l10n?.authResetPasswordTitle ?? 'Reset password',
            description:
                l10n?.authResetPasswordLead ??
                'Use the email attached to your account to receive a reset code.',
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthCodeFieldRow(
            controller: _codeController,
            label: l10n?.authCodeLabel ?? 'Verification code',
            buttonLabel: state.cooldownSeconds == null
                ? l10n?.authSendCode ?? 'Send code'
                : l10n?.authSendCodeAgain(state.cooldownSeconds!) ??
                      'Send again (${state.cooldownSeconds}s)',
            isLoading: state.isSendingCode,
            onSendCode: () async {
              notifier.updateEmail(_emailController.text);
              if (_emailController.text.trim().isEmpty) {
                await AppToast.show(
                  context,
                  l10n?.authEmailRequiredToast ?? 'Please enter your email.',
                );
                return;
              }
              await notifier.sendResetCode();
            },
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authNewPasswordLabel ?? 'New password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _confirmPasswordController,
            label: l10n?.authConfirmPasswordLabel ?? 'Confirm password',
            hint:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
          if ((state.errorMessage?.isNotEmpty ?? false) || success != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(error: state.errorMessage, success: success),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authResetPasswordAction ?? 'Reset password',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updateCode(_codeController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateConfirmPassword(_confirmPasswordController.text);
              if (!_validateSubmit(context, l10n)) {
                return;
              }
              final passwordsMatch = notifier.validatePasswordMatch(
                message:
                    l10n?.authPasswordsDoNotMatch ?? 'Passwords do not match.',
              );
              if (!passwordsMatch) {
                return;
              }
              final ok = await notifier.resetPassword();
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.authResetPasswordSuccess ??
                          'Password updated. Please sign in again.',
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
            prompt:
                l10n?.authRememberPasswordPrompt ?? 'Remember your password?',
            actionLabel: l10n?.authSignIn ?? 'Sign in',
            onPressed: () => context.push('/login'),
          ),
        ],
      ),
    );
  }

  bool _validateSubmit(BuildContext context, AppLocalizations? l10n) {
    final message = switch ((
      _emailController.text.trim().isEmpty,
      _codeController.text.trim().isEmpty,
      _passwordController.text.trim().isEmpty,
      _confirmPasswordController.text.trim().isEmpty,
    )) {
      (true, _, _, _) =>
        l10n?.authEmailRequiredToast ?? 'Please enter your email.',
      (_, true, _, _) =>
        l10n?.authCodeRequiredToast ?? 'Please enter the verification code.',
      (_, _, true, _) =>
        l10n?.authPasswordRequiredToast ?? 'Please enter your password.',
      (_, _, _, true) =>
        l10n?.authConfirmPasswordRequiredToast ??
            'Please confirm your password.',
      _ => null,
    };
    if (message == null) {
      return true;
    }
    AppToast.show(context, message);
    return false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/presentation/providers/auth_account_provider.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class ChangeEmailPage extends ConsumerStatefulWidget {
  const ChangeEmailPage({super.key});

  @override
  ConsumerState<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends ConsumerState<ChangeEmailPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(authAccountProvider);
    final accountNotifier = ref.read(authAccountProvider.notifier);
    final session = ref.watch(authSessionProvider);
    final l10n = AppLocalizations.of(context);
    final currentEmail = session.user?.email;
    final success = accountState.successMessage?.isNotEmpty == true
        ? accountState.successMessage
        : null;

    return AuthShell(
      badge: l10n?.authChangeEmailBadge ?? 'AUTH / EMAIL',
      title: l10n?.authChangeEmailTitle ?? 'Move account email carefully.',
      description:
          l10n?.authChangeEmailDescription ??
          'Verify the new address before it becomes the account login email.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthFormHeader(
            title: l10n?.authChangeEmailFormTitle ?? 'Change email',
            description: currentEmail == null
                ? l10n?.authChangeEmailSignedOutLead ??
                      'Sign in before changing the account email.'
                : l10n?.authChangeEmailLead(currentEmail) ??
                      'Current email: $currentEmail',
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          AuthTextField(
            controller: _emailController,
            label: l10n?.authNewEmailLabel ?? 'New email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthCodeFieldRow(
            controller: _codeController,
            label: l10n?.authCodeLabel ?? 'Verification code',
            buttonLabel: accountState.lastCooldownSeconds == null
                ? l10n?.authSendCode ?? 'Send code'
                : l10n?.authSendCodeAgain(accountState.lastCooldownSeconds!) ??
                      'Send again (${accountState.lastCooldownSeconds}s)',
            isLoading: accountState.isSendingCode,
            onSendCode: currentEmail == null
                ? null
                : () async {
                    if (_emailController.text.trim().isEmpty) {
                      await AppToast.show(
                        context,
                        l10n?.authEmailRequiredToast ??
                            'Please enter your email.',
                      );
                      return;
                    }
                    await accountNotifier.sendVerificationCode(
                      email: _emailController.text,
                      scene: AuthVerificationScene.changeEmail,
                    );
                  },
          ),
          if ((accountState.errorMessage?.isNotEmpty ?? false) ||
              success != null) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(
              error: accountState.errorMessage,
              success: success,
            ),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authChangeEmailSubmit ?? 'Update email',
            isLoading: accountState.isSubmitting,
            onPressed: currentEmail == null
                ? null
                : () async {
                    if (!_validateSubmit(context, l10n)) {
                      return;
                    }
                    final ok = await accountNotifier.changeEmail(
                      newEmail: _emailController.text,
                      code: _codeController.text,
                    );
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.authChangeEmailSuccess ?? 'Email updated.',
                          ),
                        ),
                      );
                    }
                  },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthFooterAction(
            prompt: currentEmail == null
                ? l10n?.authNotSignedIn ?? 'Not signed in yet.'
                : l10n?.authBackHomePrompt ?? 'Back to home?',
            actionLabel: currentEmail == null
                ? l10n?.authSignIn ?? 'Sign in'
                : l10n?.todayHeroTitle ?? 'Today',
            onPressed: () =>
                context.push(currentEmail == null ? '/login' : '/'),
          ),
        ],
      ),
    );
  }

  bool _validateSubmit(BuildContext context, AppLocalizations? l10n) {
    final message = switch ((
      _emailController.text.trim().isEmpty,
      _codeController.text.trim().isEmpty,
    )) {
      (true, _) => l10n?.authEmailRequiredToast ?? 'Please enter your email.',
      (_, true) =>
        l10n?.authCodeRequiredToast ?? 'Please enter the verification code.',
      _ => null,
    };
    if (message == null) {
      return true;
    }
    AppToast.show(context, message);
    return false;
  }
}

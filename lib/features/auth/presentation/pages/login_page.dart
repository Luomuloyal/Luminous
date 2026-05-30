import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/feedback/app_toast.dart';
import 'package:luminous/features/auth/presentation/providers/login_form_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return AuthShell(
      badge: l10n?.authLoginBadge ?? 'AUTH / LOGIN',
      title: l10n?.authLoginTitle ?? 'Sign in with calm, not clutter.',
      description:
          l10n?.authLoginDescription ??
          'Use your Lucent account to enter the rebuilt medication flow, then layer in reminders, snapshots, and multilingual health routines.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthFormHeader(
            title: l10n?.authWelcomeBack ?? 'Welcome back',
            description:
                l10n?.authLoginLead ??
                'Start with email, then choose password or verification code.',
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<AuthLoginMode>(
              segments: <ButtonSegment<AuthLoginMode>>[
                ButtonSegment<AuthLoginMode>(
                  value: AuthLoginMode.password,
                  label: SizedBox(
                    width: 96,
                    child: Text(
                      l10n?.authModePassword ?? 'Password',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                ButtonSegment<AuthLoginMode>(
                  value: AuthLoginMode.code,
                  label: SizedBox(
                    width: 96,
                    child: Text(
                      l10n?.authModeCode ?? 'Code',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
              selected: <AuthLoginMode>{state.mode},
              onSelectionChanged: (next) {
                notifier.updateMode(next.first);
              },
            ),
          ),
          const SizedBox(height: AppSpacingTokens.lg),
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AnimatedSwitcher(
            duration: 160.ms,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: state.mode == AuthLoginMode.password
                ? AuthTextField(
                    key: const ValueKey('password-login-field'),
                    controller: _passwordController,
                    label: l10n?.authPasswordLabel ?? 'Password',
                    hint:
                        l10n?.authPasswordHint ??
                        'At least 8 characters, ideally with mixed case and numbers',
                    obscureText: true,
                  )
                : AuthCodeFieldRow(
                    key: const ValueKey('code-login-field'),
                    controller: _codeController,
                    label: l10n?.authCodeLabel ?? 'Verification code',
                    buttonLabel: l10n?.authSendCode ?? 'Send code',
                    isLoading: state.isSendingCode,
                    onSendCode: () async {
                      notifier.updateEmail(_emailController.text);
                      if (_emailController.text.trim().isEmpty) {
                        await AppToast.show(
                          context,
                          l10n?.authEmailRequiredToast ??
                              'Please enter your email.',
                        );
                        return;
                      }
                      await notifier.sendCode();
                    },
                  ),
          ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            AuthStatusMessage(error: state.errorMessage),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authSignIn ?? 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateCode(_codeController.text);
              if (!_validateSubmit(context, l10n, state.mode)) {
                return;
              }
              await notifier.submit();
            },
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          AuthLoginActionRow(
            registerPrompt: l10n?.authNeedAccountPrompt ?? 'Need an account?',
            registerLabel: l10n?.authRegisterNowAction ?? 'Register now',
            onRegister: () => context.push('/register'),
            forgotPasswordLabel:
                l10n?.authForgotPasswordPrompt ?? 'Forgot your password?',
            onForgotPassword: () => context.push('/forgot-password'),
          ),
        ],
      ),
    );
  }

  bool _validateSubmit(
    BuildContext context,
    AppLocalizations? l10n,
    AuthLoginMode mode,
  ) {
    final message = switch ((
      _emailController.text.trim().isEmpty,
      mode == AuthLoginMode.password && _passwordController.text.trim().isEmpty,
      mode == AuthLoginMode.code && _codeController.text.trim().isEmpty,
    )) {
      (true, _, _) =>
        l10n?.authEmailRequiredToast ?? 'Please enter your email.',
      (_, true, _) =>
        l10n?.authPasswordRequiredToast ?? 'Please enter your password.',
      (_, _, true) =>
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

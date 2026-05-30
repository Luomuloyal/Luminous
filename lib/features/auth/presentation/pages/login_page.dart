import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
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
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

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
          Text(
            l10n?.authWelcomeBack ?? 'Welcome back',
            style: typography.displayMd,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n?.authLoginLead ??
                'Start with email, then choose password or verification code.',
            style: typography.bodySm.copyWith(color: surface.body),
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
          if (state.mode == AuthLoginMode.password)
            AuthTextField(
              controller: _passwordController,
              label: l10n?.authPasswordLabel ?? 'Password',
              helperText:
                  l10n?.authPasswordHint ??
                  'At least 8 characters, ideally with mixed case and numbers',
              obscureText: true,
            )
          else
            Row(
              children: [
                Expanded(
                  child: AuthTextField(
                    controller: _codeController,
                    label: l10n?.authCodeLabel ?? 'Verification code',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: AppSpacingTokens.sm),
                OutlinedButton(
                  onPressed: () async {
                    notifier.updateEmail(_emailController.text);
                    await notifier.sendCode();
                  },
                  child: Text(l10n?.authSendCode ?? 'Send code'),
                ),
              ],
            ),
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) ...[
            const SizedBox(height: AppSpacingTokens.md),
            Text(
              state.errorMessage!,
              style: typography.bodySm.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: AppSpacingTokens.xl),
          AuthPrimaryButton(
            label: l10n?.authSignIn ?? 'Sign in',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateCode(_codeController.text);
              await notifier.submit();
            },
          ),
        ],
      ),
    );
  }
}

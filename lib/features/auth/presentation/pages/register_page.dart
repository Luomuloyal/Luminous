import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/constants/app_breakpoints.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/register_form_provider.dart';
import 'package:luminous/features/auth/presentation/widgets/auth_shell.dart';
import 'package:luminous/l10n/app_localizations.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < AppBreakpoints.mobile
        ? AppTypographyTokens.mobile(theme.colorScheme.onSurface)
        : AppTypographyTokens.desktop(theme.colorScheme.onSurface);

    return AuthShell(
      badge: l10n?.authRegisterBadge ?? 'AUTH / REGISTER',
      title:
          l10n?.authRegisterTitle ?? 'Create the clean version first.',
      description:
          l10n?.authRegisterDescription ??
          'Register once, then grow medication plans, reminders, and multilingual health workflows on top of Lucent.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.authCreateAccount ?? 'Create account',
            style: typography.displayMd,
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Text(
            l10n?.authRegisterLead ??
                'Email and password are enough to start. Nickname is optional.',
            style: typography.bodySm.copyWith(color: surface.body),
          ),
          const SizedBox(height: AppSpacingTokens.xl),
          AuthTextField(
            controller: _emailController,
            label: l10n?.authEmailLabel ?? 'Email',
            hint: l10n?.authEmailHint ?? 'name@example.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _passwordController,
            label: l10n?.authPasswordLabel ?? 'Password',
            helperText:
                l10n?.authPasswordHint ??
                'At least 8 characters, ideally with mixed case and numbers',
            obscureText: true,
          ),
          const SizedBox(height: AppSpacingTokens.md),
          AuthTextField(
            controller: _nicknameController,
            label: l10n?.authNicknameLabel ?? 'Nickname',
            hint: l10n?.authNicknameHint ?? 'Optional',
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
            label: l10n?.authCreateAccountAction ?? 'Create account',
            isLoading: state.isSubmitting,
            onPressed: () async {
              notifier.updateEmail(_emailController.text);
              notifier.updatePassword(_passwordController.text);
              notifier.updateNickname(_nicknameController.text);
              await notifier.submit();
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/features/auth/data/session_sync_service.dart';
import 'package:luminous/shared/widgets/auth/auth.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/register/presentation/register.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/login_provider.dart';

/// 登录页。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.authApi = const AuthApi()});
  final AuthApi authApi;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  final _identifierType = AuthIdentifierType.email;
  var _loginMode = AuthLoginMode.password;
  var _obscurePassword = true;
  AuthApi get _authApi => widget.authApi;

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  // -- labels and validation --

  String _identifierLabel() => _identifierType == AuthIdentifierType.phone
      ? _l10n.authPhoneLabel
      : _l10n.authEmailLabel;

  String _loginModeLabel(AuthLoginMode mode) => mode == AuthLoginMode.password
      ? _l10n.authPasswordLoginMode
      : _l10n.authCodeLoginMode;

  String? _identifierValidator(String? value) => ref
      .read(loginNotifierProvider.notifier)
      .validateIdentifier(value ?? '', _identifierType);

  String? _passwordValidator(String? value) =>
      ref.read(loginNotifierProvider.notifier).validatePassword(value ?? '');

  String? _codeValidator(String? value) =>
      ref.read(loginNotifierProvider.notifier).validateCode(value ?? '');

  // -- actions --

  void _onLoginModeChanged(AuthLoginMode mode) {
    if (ref.read(loginNotifierProvider).submitting) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loginMode = mode;
      _codeCtrl.clear();
    });
    ref.read(loginNotifierProvider.notifier).onIdentifierChanged('');
  }

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    final id = _identifierCtrl.text.trim();
    final error = _identifierValidator(id);
    if (error != null) {
      ToastUtils.instance.show(context, error);
      return;
    }
    final ok = await ref
        .read(loginNotifierProvider.notifier)
        .sendCode(identifier: id, type: _identifierType, authApi: _authApi);
    if (ok && mounted) {
      ToastUtils.instance.show(context, _l10n.authCodeSentSuccess);
    }
  }

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final notifier = ref.read(loginNotifierProvider.notifier);
    final identifier = _identifierCtrl.text.trim();
    if (_loginMode == AuthLoginMode.code && notifier.codeTarget != identifier) {
      ToastUtils.instance.show(context, _l10n.loginNeedCodeForCurrentAccount);
      return;
    }
    try {
      final result = await notifier.login(
        authApi: _authApi,
        type: _identifierType,
        identifier: identifier,
        password: _passwordCtrl.text,
        code: _codeCtrl.text.trim(),
        mode: _loginMode,
      );
      await ref.read(authServiceProvider).loginSuccess(result.user);
      await sessionSyncService.syncForUser(result.user.id);
      if (!mounted) return;
      ToastUtils.instance.show(context, _l10n.loginSuccess);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.maybePop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (_loginMode == AuthLoginMode.code && e.code == 'NOT_REGISTERED') {
        final confirmed = await _showAutoRegisterDialog(e.message);
        if (!mounted || confirmed != true) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RegisterPage(
              authApi: _authApi,
              initialIdentifierType: _identifierType,
              initialIdentifier: identifier,
              initialCode: _codeCtrl.text.trim(),
            ),
          ),
        );
        return;
      }
      ToastUtils.instance.show(
        context,
        e.message.isNotEmpty ? e.message : '登录失败',
      );
    }
  }

  Future<bool?> _showAutoRegisterDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_l10n.loginAutoRegisterTitle),
          content: Text(
            message.isEmpty ? _l10n.loginAutoRegisterPrompt : message,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_l10n.loginAutoRegisterCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(_l10n.loginAutoRegisterConfirm),
            ),
          ],
        );
      },
    );
  }

  // -- build --

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginNotifierProvider);
    final l10n = _l10n;

    return AuthPageScaffold(
      children: [
        _buildTopBar(),
        const SizedBox(height: 10),
        AuthHeroCard(
          palette: SoftBannerPalettes.authOf(context),
          icon: Icons.health_and_safety_rounded,
          title: l10n.loginHeroTitle,
          subtitle: l10n.loginHeroSubtitle(
            _identifierLabel(),
            _loginModeLabel(_loginMode),
          ),
        ),
        const SizedBox(height: 10),
        AuthMethodSwitcher(
          items: [
            AuthMethodItem(
              label: _loginModeLabel(AuthLoginMode.password),
              selected: _loginMode == AuthLoginMode.password,
              onTap: () => _onLoginModeChanged(AuthLoginMode.password),
            ),
            AuthMethodItem(
              label: _loginModeLabel(AuthLoginMode.code),
              selected: _loginMode == AuthLoginMode.code,
              onTap: () => _onLoginModeChanged(AuthLoginMode.code),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildForm(formState),
        const SizedBox(height: 14),
        _buildLoginButton(formState),
        const SizedBox(height: 8),
        _buildHelperText(),
        const SizedBox(height: 8),
        AuthLegalHint(
          onTapAgreement: () => Navigator.pushNamed(context, '/user-agreement'),
          onTapPrivacy: () => Navigator.pushNamed(context, '/privacy-policy'),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final canPop = Navigator.canPop(context);
    return Row(
      children: [
        if (canPop)
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: theme.cardTheme.color ?? scheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: scheme.outline),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: scheme.onSurface,
              ),
            ),
          ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RegisterPage(
                authApi: _authApi,
                initialIdentifierType: AuthIdentifierType.email,
              ),
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: const Size(52, 32),
            foregroundColor: scheme.primary,
            textStyle: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: Text(_l10n.loginRegisterAction),
        ),
      ],
    );
  }

  Widget _buildForm(LoginFormState form) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            controller: _identifierCtrl,
            label: _identifierLabel(),
            prefixIcon: _identifierType == AuthIdentifierType.phone
                ? Icons.phone_android_rounded
                : Icons.email_outlined,
            validator: _identifierValidator,
            onChanged: (v) =>
                ref.read(loginNotifierProvider.notifier).onIdentifierChanged(v),
          ),
          if (_loginMode == AuthLoginMode.password) ...[
            const SizedBox(height: 14),
            _buildTextField(
              controller: _passwordCtrl,
              label: _l10n.authPasswordLabel,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              validator: _passwordValidator,
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => ToastUtils.instance.show(
                  context,
                  _l10n.loginForgotPasswordPending,
                ),
                child: Text(_l10n.loginForgotPasswordAction),
              ),
            ),
          ],
          if (_loginMode == AuthLoginMode.code) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _codeCtrl,
                    label: _l10n.authCodeLabel,
                    prefixIcon: Icons.pin_rounded,
                    validator: _codeValidator,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: form.sendingCode || form.codeCountdownSeconds > 0
                      ? null
                      : _onSendCode,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(80, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    form.codeCountdownSeconds > 0
                        ? '${form.codeCountdownSeconds}s'
                        : '发送验证码',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 1.4),
        ),
      ),
    );
  }

  Widget _buildLoginButton(LoginFormState form) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: form.submitting ? null : _onLoginPressed,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: form.submitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                _l10n.loginButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => RegisterPage(
                authApi: _authApi,
                initialIdentifierType: AuthIdentifierType.email,
              ),
            ),
          ),
          child: Text(_l10n.loginRegisterAction),
        ),
      ],
    );
  }
}

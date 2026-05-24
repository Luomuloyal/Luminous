import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/register/presentation/register.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/viewmodels/auth.dart';

import '../controllers/login_controller.dart';

/// 登录页。
///
/// 页面默认展示邮箱登录（密码/验证码），保留手机号分支逻辑供后续灰度开关。
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.authApi = const AuthApi(), this.controller});

  final AuthApi authApi;
  final LoginController? controller;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final LoginController _controller =
      widget.controller ??
      LoginController(
        authApi: widget.authApi,
        onLoginSuccess: (user) =>
            ref.read(authServiceProvider).loginSuccess(user),
      );

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  GlobalKey<FormState> get _formKey => _controller.formKey;
  TextEditingController get _identifierController =>
      _controller.identifierController;
  TextEditingController get _passwordController =>
      _controller.passwordController;
  TextEditingController get _codeController => _controller.codeController;
  AuthIdentifierType get _identifierType => _controller.identifierType;
  AuthLoginMode get _loginMode => _controller.loginMode;
  bool get _obscurePassword => _controller.obscurePassword;
  bool get _sendingCode => _controller.sendingCode;
  bool get _submitting => _controller.submitting;
  int get _codeCountdownSeconds => _controller.codeCountdownSeconds;

  String _identifierLabel(AuthIdentifierType type) {
    return _controller.identifierLabel(_l10n, type);
  }

  String _identifierHint(AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? _l10n.loginIdentifierHintPhone
        : _l10n.loginIdentifierHintEmail;
  }

  String _loginModeLabel(AuthLoginMode mode) {
    return _controller.loginModeLabel(_l10n, mode);
  }

  String? _identifierValidator(String? value) {
    return _controller.identifierValidator(_l10n, value);
  }

  String? _passwordValidator(String? value) {
    return _controller.passwordValidator(_l10n, value);
  }

  String? _codeValidator(String? value) {
    return _controller.codeValidator(_l10n, value);
  }

  void _openUserAgreement() {
    Navigator.pushNamed(context, '/user-agreement');
  }

  void _openPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  void _onTapForgotPassword() {
    _controller.onTapForgotPassword(context, _l10n);
  }

  void _onLoginModeChanged(AuthLoginMode mode) {
    _controller.onLoginModeChanged(context, mode);
  }

  Future<void> _onSendCode() async {
    await _controller.onSendCode(context, _l10n);
  }

  Future<void> _onLoginPressed() async {
    await _controller.onLoginPressed(context, _l10n);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: _controller,
      global: false,
      builder: (_) {
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
                _identifierLabel(_identifierType),
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
            _buildFormCard(),
            const SizedBox(height: 14),
            _buildLoginButton(),
            const SizedBox(height: 8),
            _buildHelperText(),
            const SizedBox(height: 8),
            AuthLegalHint(
              onTapAgreement: _openUserAgreement,
              onTapPrivacy: _openPrivacyPolicy,
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
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
                color: isDark ? scheme.onSurface : scheme.onSurface,
              ),
            ),
          ),
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RegisterPage(
                  authApi: widget.authApi,
                  initialIdentifierType: AuthIdentifierType.email,
                ),
              ),
            );
          },
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

  Widget _buildFormCard() {
    return AuthSurfaceCard(
      ornamentKey: 'auth.login.form',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _identifierController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: _identifierLabel(_identifierType),
                  hintText: _identifierHint(_identifierType),
                  prefixIcon: Icons.email_outlined,
                ),
                validator: _identifierValidator,
              ),
              if (_loginMode == AuthLoginMode.password) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: _buildInputDecoration(
                    labelText: _l10n.authPasswordLabel,
                    hintText: _l10n.authPasswordHint,
                    prefixIcon: Icons.lock_outline_rounded,
                    suffixIcon: IconButton(
                      onPressed: () => _controller.toggleObscurePassword(),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  validator: _passwordValidator,
                ),
              ],
              if (_loginMode == AuthLoginMode.code) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        decoration: _buildInputDecoration(
                          labelText: _l10n.authCodeLabel,
                          hintText: _l10n.authCodeHint,
                          prefixIcon: Icons.pin_outlined,
                        ),
                        validator: _codeValidator,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _sendingCode || _codeCountdownSeconds > 0
                            ? null
                            : _onSendCode,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _codeCountdownSeconds > 0
                              ? '${_codeCountdownSeconds}s'
                              : _l10n.authSendCode,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.78),
        fontWeight: FontWeight.w600,
      ),
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
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitting ? null : _onLoginPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _submitting
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: _onTapForgotPassword,
          child: Text(_l10n.loginForgotPasswordAction),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RegisterPage(
                  authApi: widget.authApi,
                  initialIdentifierType: AuthIdentifierType.email,
                ),
              ),
            );
          },
          child: Text(_l10n.loginRegisterAction),
        ),
      ],
    );
  }
}

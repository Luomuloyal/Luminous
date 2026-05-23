import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/pages/Login/controllers/login_controller.dart';
import 'package:luminous/features/auth/providers/auth_service_provider.dart';
import 'package:luminous/viewmodels/auth.dart';

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
                builder: (_) => RegisterView(
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
                keyboardType: _identifierType == AuthIdentifierType.phone
                    ? TextInputType.phone
                    : TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: _identifierLabel(_identifierType),
                  hintText: _identifierType == AuthIdentifierType.phone
                      ? _l10n.loginIdentifierHintPhone
                      : _l10n.loginIdentifierHintEmail,
                  prefixIcon: _identifierType == AuthIdentifierType.phone
                      ? Icons.phone_iphone_rounded
                      : Icons.email_outlined,
                ),
                validator: _identifierValidator,
                onChanged: _controller.onIdentifierChanged,
              ),
              const SizedBox(height: 10),
              if (_loginMode == AuthLoginMode.password)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: _buildInputDecoration(
                    labelText: _l10n.authPasswordLabel,
                    hintText: _l10n.authPasswordHint,
                    prefixIcon: Icons.lock_rounded,
                    suffixIcon: IconButton(
                      onPressed: _controller.toggleObscurePassword,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                      ),
                    ),
                  ),
                  validator: _passwordValidator,
                  onFieldSubmitted: (_) => _onLoginPressed(),
                )
              else
                _buildCodeRow(),
              const SizedBox(height: 4),
              _buildActionLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeRow() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            decoration: _buildInputDecoration(
              labelText: _l10n.authCodeLabel,
              hintText: _l10n.authCodeHint,
              prefixIcon: Icons.verified_user_rounded,
            ),
            validator: _codeValidator,
            onFieldSubmitted: (_) => _onLoginPressed(),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: (_sendingCode || _codeCountdownSeconds > 0)
              ? null
              : _onSendCode,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            minimumSize: const Size(78, 48),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
          ),
          child: _sendingCode
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _codeCountdownSeconds > 0
                      ? '${_codeCountdownSeconds}s'
                      : _l10n.authSendCode,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildActionLinks() {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Spacer(),
        TextButton(
          onPressed: _onTapForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: scheme.primary,
          ),
          child: Text(_l10n.loginForgotPasswordAction),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final fillColor =
        theme.inputDecorationTheme.fillColor ??
        (isDark ? const Color(0xFF172033) : const Color(0xFFFCFEFF));
    final enabledBorderColor = Color.alphaBlend(
      scheme.primary.withValues(alpha: isDark ? 0.18 : 0.10),
      scheme.outline.withValues(alpha: isDark ? 0.72 : 0.42),
    );
    final focusedBorderColor = Color.lerp(
      scheme.primary,
      scheme.secondary,
      0.16,
    )!;
    final errorBorderColor = Color.alphaBlend(
      scheme.error.withValues(alpha: 0.28),
      scheme.error,
    );
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        size: 22,
        color: Color.lerp(scheme.primary, scheme.onSurface, 0.18),
      ),
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      prefixIconConstraints: const BoxConstraints(minWidth: 50, minHeight: 50),
      suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: enabledBorderColor, width: 1.1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: enabledBorderColor, width: 1.1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: focusedBorderColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: errorBorderColor, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      labelStyle: TextStyle(
        color: Color.lerp(scheme.onSurfaceVariant, scheme.onSurface, 0.26),
        fontSize: 13.5,
        fontWeight: FontWeight.w700,
      ),
      hintStyle: TextStyle(
        color: Color.lerp(
          scheme.onSurfaceVariant,
          scheme.onSurface,
          0.18,
        )?.withValues(alpha: 0.82),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _submitting ? null : _onLoginPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
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
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      _loginMode == AuthLoginMode.password
          ? _l10n.loginHelperPasswordEmailOnly
          : _l10n.loginHelperCodeEmailOnly,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.45,
      ),
    );
  }
}

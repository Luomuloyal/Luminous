import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/auth.dart';

import '../controllers/register_controller.dart';

/// 注册页。
///
/// 页面默认展示邮箱注册，保留手机号分支逻辑供后续灰度开关。
class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
    this.authApi = const AuthApi(),
    this.initialIdentifierType = AuthIdentifierType.email,
    this.initialIdentifier = '',
    this.initialCode = '',
    this.controller,
  });

  final AuthApi authApi;
  final AuthIdentifierType initialIdentifierType;
  final String initialIdentifier;
  final String initialCode;
  final RegisterController? controller;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final RegisterController _controller =
      widget.controller ??
      RegisterController(
        authApi: widget.authApi,
        initialIdentifierType: widget.initialIdentifierType,
        initialIdentifier: widget.initialIdentifier,
        initialCode: widget.initialCode,
      );

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String _identifierLabel(AuthIdentifierType type) {
    return _controller.identifierLabel(_l10n, type);
  }

  String _identifierHint(AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? _l10n.loginIdentifierHintPhone
        : _l10n.loginIdentifierHintEmail;
  }

  GlobalKey<FormState> get _formKey => _controller.formKey;
  TextEditingController get _identifierController =>
      _controller.identifierController;
  TextEditingController get _usernameController =>
      _controller.usernameController;
  TextEditingController get _codeController => _controller.codeController;
  TextEditingController get _passwordController =>
      _controller.passwordController;
  TextEditingController get _confirmController => _controller.confirmController;
  AuthIdentifierType get _identifierType => _controller.identifierType;
  bool get _agreed => _controller.agreed;
  bool get _obscurePassword => _controller.obscurePassword;
  bool get _obscureConfirm => _controller.obscureConfirm;
  bool get _sendingCode => _controller.sendingCode;
  bool get _submitting => _controller.submitting;
  int get _codeCountdownSeconds => _controller.codeCountdownSeconds;

  void _onTapAgreement() {
    Navigator.pushNamed(context, '/user-agreement');
  }

  void _onTapPrivacy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  String? _identifierValidator(String? value) {
    return _controller.identifierValidator(_l10n, value);
  }

  String? _codeValidator(String? value) {
    return _controller.codeValidator(_l10n, value);
  }

  String? _usernameValidator(String? value) {
    return _controller.usernameValidator(_l10n, value);
  }

  String? _passwordValidator(String? value) {
    return _controller.passwordValidator(_l10n, value);
  }

  String? _confirmValidator(String? value) {
    return _controller.confirmValidator(_l10n, value);
  }

  Future<void> _onSendCode() async {
    await _controller.onSendCode(context, _l10n);
  }

  Future<void> _onRegisterPressed() async {
    await _controller.onRegisterPressed(context, _l10n);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RegisterController>(
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
              icon: Icons.person_add_alt_1_rounded,
              title: l10n.registerHeroTitle,
              subtitle: l10n.registerHeroSubtitle(
                _identifierLabel(_identifierType),
              ),
            ),
            const SizedBox(height: 14),
            _buildFormCard(),
            const SizedBox(height: 12),
            AuthAgreementRow(
              agreed: _agreed,
              onChanged: (value) => _controller.setAgreed(value),
              onTapAgreement: _onTapAgreement,
              onTapPrivacy: _onTapPrivacy,
            ),
            const SizedBox(height: 14),
            _buildRegisterButton(),
            const SizedBox(height: 8),
            _buildHelperText(),
          ],
        );
      },
    );
  }

  Widget _buildTopBar() {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Row(
      children: [
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            _l10n.registerTopTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return AuthSurfaceCard(
      ornamentKey: 'auth.register.form',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: _l10n.registerUsernameLabel,
                  hintText: _l10n.registerUsernameHint,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: _usernameValidator,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
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
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                decoration: _buildInputDecoration(
                  labelText: _l10n.authConfirmPasswordLabel,
                  hintText: _l10n.authConfirmPasswordHint,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () => _controller.toggleObscureConfirm(),
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: _confirmValidator,
              ),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitting ? null : _onRegisterPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
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
                _l10n.registerButton,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/login');
        },
        child: Text(_l10n.loginButton),
      ),
    );
  }
}

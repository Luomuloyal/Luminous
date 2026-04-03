import 'dart:async';

import 'package:flutter/material.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 注册页。
///
/// 支持手机号/邮箱双栈注册，仅保留业务验证码校验。
class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
    this.authApi = const AuthApi(),
    this.initialIdentifierType = AuthIdentifierType.phone,
    this.initialIdentifier = '',
    this.initialCode = '',
  });

  final AuthApi authApi;
  final AuthIdentifierType initialIdentifierType;
  final String initialIdentifier;
  final String initialCode;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  static const int _codeCooldownSeconds = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  AuthIdentifierType _identifierType = AuthIdentifierType.phone;
  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _sendingCode = false;
  bool _submitting = false;
  String _codeTarget = '';
  Timer? _codeCountdownTimer;
  int _codeCountdownSeconds = 0;

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');
  static final RegExp _usernameRegExp = RegExp(r'^\S{2,30}$');

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  String _identifierLabel(AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? _l10n.authPhoneLabel
        : _l10n.authEmailLabel;
  }

  String _registerMethodLabel(AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? _l10n.authPhoneRegisterMethod
        : _l10n.authEmailRegisterMethod;
  }

  @override
  void initState() {
    super.initState();
    _identifierType = widget.initialIdentifierType;
    _identifierController.text = widget.initialIdentifier;
    _codeController.text = widget.initialCode;
    final initialCode = widget.initialCode.trim();
    _codeTarget = initialCode.isEmpty ? '' : widget.initialIdentifier.trim();
  }

  @override
  void dispose() {
    _codeCountdownTimer?.cancel();
    _identifierController.dispose();
    _usernameController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onTapAgreement() {
    Navigator.pushNamed(context, '/user-agreement');
  }

  void _onTapPrivacy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  String? _identifierValidator(String? value) {
    final identifier = (value ?? '').trim();
    if (identifier.isEmpty) {
      return _identifierType == AuthIdentifierType.phone
          ? _l10n.authValidationEnterPhone
          : _l10n.authValidationEnterEmail;
    }
    if (_identifierType == AuthIdentifierType.phone &&
        !_phoneRegExp.hasMatch(identifier)) {
      return _l10n.authValidationInvalidPhone;
    }
    if (_identifierType == AuthIdentifierType.email &&
        !_emailRegExp.hasMatch(identifier)) {
      return _l10n.authValidationInvalidEmail;
    }
    return null;
  }

  String? _codeValidator(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return _l10n.authValidationEnterCode;
    }
    if (!_codeRegExp.hasMatch(code)) {
      return _l10n.authValidationCodeRule;
    }
    return null;
  }

  String? _usernameValidator(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return null;
    }
    if (!_usernameRegExp.hasMatch(username)) {
      return AppI18nText.pick(
        zh: '用户名需为2-30个字符且不能包含空格',
        en: 'Username must be 2-30 chars with no spaces',
      );
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final pwd = value ?? '';
    if (pwd.isEmpty) {
      return _l10n.authValidationEnterPassword;
    }
    if (!_passwordRegExp.hasMatch(pwd)) {
      return _l10n.authValidationPasswordRule;
    }
    return null;
  }

  String? _confirmValidator(String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) {
      return _l10n.authValidationEnterConfirmPassword;
    }
    if (confirm != _passwordController.text) {
      return _l10n.authValidationPasswordMismatch;
    }
    return null;
  }

  void _toggleIdentifierType(AuthIdentifierType type) {
    if (_identifierType == type) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _identifierType = type;
      _clearCodeSession(clearInput: true);
    });
  }

  void _clearCodeSession({required bool clearInput}) {
    _resetCodeCooldown();
    _codeTarget = '';
    if (clearInput) {
      _codeController.clear();
    }
  }

  void _startCodeCooldown() {
    _codeCountdownTimer?.cancel();
    setState(() {
      _codeCountdownSeconds = _codeCooldownSeconds;
    });
    _codeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_codeCountdownSeconds <= 1) {
        timer.cancel();
        setState(() {
          _codeCountdownSeconds = 0;
        });
        return;
      }
      setState(() {
        _codeCountdownSeconds -= 1;
      });
    });
  }

  void _resetCodeCooldown() {
    _codeCountdownTimer?.cancel();
    _codeCountdownTimer = null;
    if (_codeCountdownSeconds == 0) {
      return;
    }
    _codeCountdownSeconds = 0;
  }

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    if (_sendingCode || _codeCountdownSeconds > 0) {
      return;
    }

    final identifier = _identifierController.text.trim();
    final error = _identifierValidator(identifier);
    if (error != null) {
      ToastUtils.instance.show(context, error);
      return;
    }

    setState(() {
      _sendingCode = true;
    });

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await widget.authApi.sendPhoneCode(
              phone: identifier,
              scene: AuthCodeScene.register,
            )
          : await widget.authApi.sendEmailCode(
              email: identifier,
              scene: AuthCodeScene.register,
            );

      if (!mounted) {
        return;
      }

      setState(() {
        _codeTarget = identifier;
      });
      _startCodeCooldown();
      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? _l10n.authCodeSentSuccess : response.msg,
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(context, _resolveAuthErrorMessage(e));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _sendingCode = false;
        });
      }
    }
  }

  Future<void> _onRegisterPressed() async {
    FocusScope.of(context).unfocus();
    if (_submitting) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final identifier = _identifierController.text.trim();
    final username = _usernameController.text.trim();
    if (_codeTarget != identifier) {
      ToastUtils.instance.show(
        context,
        _l10n.registerNeedCodeForCurrentAccount,
      );
      return;
    }
    if (!_agreed) {
      ToastUtils.instance.show(context, _l10n.registerNeedAgreement);
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await widget.authApi.registerWithPhone(
              phone: identifier,
              code: _codeController.text.trim(),
              password: _passwordController.text,
              username: username,
            )
          : await widget.authApi.registerWithEmail(
              email: identifier,
              code: _codeController.text.trim(),
              password: _passwordController.text,
              username: username,
            );

      if (!mounted) {
        return;
      }

      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? _l10n.registerSuccess : response.msg,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        Navigator.maybePop(context);
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.show(context, _resolveAuthErrorMessage(e));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  String _resolveAuthErrorMessage(ApiException error) {
    switch (error.code) {
      case 'CODE_INVALID':
        return _l10n.authErrorCodeInvalid;
      case 'CODE_EXPIRED':
        return _l10n.authErrorCodeExpired;
      case 'CODE_REQUIRED':
        return _l10n.authErrorCodeRequired;
      case 'IDENTIFIER_EXISTS':
        return _identifierType == AuthIdentifierType.phone
            ? _l10n.authErrorIdentifierExistsPhoneRegistered
            : _l10n.authErrorIdentifierExistsEmailRegistered;
      case 'CODE_SEND_TOO_FREQUENT':
        return _l10n.authErrorTooFrequent;
      case 'INVALID_IDENTIFIER':
      case 'INVALID_TARGET':
        return _identifierType == AuthIdentifierType.phone
            ? _l10n.authErrorInvalidPhone
            : _l10n.authErrorInvalidEmailFormat;
      default:
        return error.message.trim().isEmpty
            ? _l10n.authErrorRequestFailed
            : error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 10),
        AuthMethodSwitcher(
          items: [
            AuthMethodItem(
              label: _registerMethodLabel(AuthIdentifierType.phone),
              selected: _identifierType == AuthIdentifierType.phone,
              onTap: () => _toggleIdentifierType(AuthIdentifierType.phone),
            ),
            AuthMethodItem(
              label: _registerMethodLabel(AuthIdentifierType.email),
              selected: _identifierType == AuthIdentifierType.email,
              onTap: () => _toggleIdentifierType(AuthIdentifierType.email),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildFormCard(),
        const SizedBox(height: 12),
        AuthAgreementRow(
          agreed: _agreed,
          onChanged: (value) {
            setState(() {
              _agreed = value;
            });
          },
          onTapAgreement: _onTapAgreement,
          onTapPrivacy: _onTapPrivacy,
        ),
        const SizedBox(height: 14),
        _buildRegisterButton(),
        const SizedBox(height: 8),
        _buildHelperText(),
      ],
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
                onChanged: (value) {
                  final identifier = value.trim();
                  final hasActiveCodeSession = _codeTarget.isNotEmpty;
                  if (hasActiveCodeSession && identifier != _codeTarget) {
                    setState(() {
                      _clearCodeSession(clearInput: false);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: AppI18nText.pick(
                    zh: '用户名(可选)',
                    en: 'Username (optional)',
                  ),
                  hintText: AppI18nText.pick(
                    zh: '用于个性化显示，例如 luminous_user',
                    en: 'Used for profile display, e.g. luminous_user',
                  ),
                  prefixIcon: Icons.person_outline_rounded,
                ),
                validator: _usernameValidator,
              ),
              const SizedBox(height: 10),
              _buildCodeRow(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.next,
                decoration: _buildInputDecoration(
                  labelText: _l10n.authPasswordLabel,
                  hintText: _l10n.authPasswordHint,
                  prefixIcon: Icons.lock_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: _passwordValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                decoration: _buildInputDecoration(
                  labelText: _l10n.authConfirmPasswordLabel,
                  hintText: _l10n.authConfirmPasswordHint,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscureConfirm = !_obscureConfirm;
                      });
                    },
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                    ),
                  ),
                ),
                validator: _confirmValidator,
                onFieldSubmitted: (_) => _onRegisterPressed(),
              ),
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
            textInputAction: TextInputAction.next,
            decoration: _buildInputDecoration(
              labelText: _l10n.authCodeLabel,
              hintText: _l10n.authCodeHint,
              prefixIcon: Icons.verified_user_rounded,
            ),
            validator: _codeValidator,
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
            minimumSize: const Size(78, 42),
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

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, size: 22),
      suffixIcon: suffixIcon,
      isDense: true,
      filled: true,
      fillColor:
          theme.inputDecorationTheme.fillColor ??
          (isDark ? const Color(0xFF1E293B) : const Color(0xFFF6F8FC)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 44),
      suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.78),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 46,
      child: FilledButton(
        onPressed: _submitting ? null : _onRegisterPressed,
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
                _l10n.registerButton,
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
      _identifierType == AuthIdentifierType.phone
          ? _l10n.registerHelperPhone
          : _l10n.registerHelperEmail,
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

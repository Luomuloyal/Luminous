import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/components/auth.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/pages/Register/register.dart';
import 'package:luminous/stores/session_sync_service.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 登录页。
///
/// 支持手机号/邮箱两种账号类型，且二者都支持密码登录与验证码登录。
class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.authApi = const AuthApi()});

  final AuthApi authApi;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const int _codeCooldownSeconds = 60;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final UserController _userController = Get.find<UserController>();

  AuthIdentifierType _identifierType = AuthIdentifierType.phone;
  AuthLoginMode _loginMode = AuthLoginMode.password;
  bool _obscurePassword = true;
  bool _sendingCode = false;
  bool _submitting = false;
  String _codeTarget = '';
  Timer? _codeCountdownTimer;
  int _codeCountdownSeconds = 0;

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  @override
  void dispose() {
    _codeCountdownTimer?.cancel();
    _identifierController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String? _identifierValidator(String? value) {
    final identifier = (value ?? '').trim();
    if (identifier.isEmpty) {
      return _identifierType == AuthIdentifierType.phone ? '请输入手机号' : '请输入邮箱';
    }
    if (_identifierType == AuthIdentifierType.phone &&
        !_phoneRegExp.hasMatch(identifier)) {
      return '手机号格式不正确';
    }
    if (_identifierType == AuthIdentifierType.email &&
        !_emailRegExp.hasMatch(identifier)) {
      return '邮箱格式不正确';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    final pwd = value ?? '';
    if (pwd.isEmpty) {
      return '请输入密码';
    }
    if (!_passwordRegExp.hasMatch(pwd)) {
      return '密码需为6-12位字母或数字';
    }
    return null;
  }

  String? _codeValidator(String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return '请输入验证码';
    }
    if (!_codeRegExp.hasMatch(code)) {
      return '验证码应为6位数字';
    }
    return null;
  }

  void _openUserAgreement() {
    Navigator.pushNamed(context, '/user-agreement');
  }

  void _openPrivacyPolicy() {
    Navigator.pushNamed(context, '/privacy-policy');
  }

  void _onTapForgotPassword() {
    ToastUtils.instance.show(context, '找回密码功能稍后补充，当前可先注册新账号或联系人工支持');
  }

  void _toggleIdentifierType() {
    FocusScope.of(context).unfocus();
    setState(() {
      _identifierType = _identifierType == AuthIdentifierType.phone
          ? AuthIdentifierType.email
          : AuthIdentifierType.phone;
      _clearCodeSession(clearInput: true);
    });
  }

  void _onLoginModeChanged(AuthLoginMode mode) {
    if (_submitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _loginMode = mode;
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
              scene: AuthCodeScene.login,
            )
          : await widget.authApi.sendEmailCode(
              email: identifier,
              scene: AuthCodeScene.login,
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
        response.msg.isEmpty ? '验证码发送成功' : response.msg,
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

  Future<void> _onLoginPressed() async {
    FocusScope.of(context).unfocus();
    if (_submitting) {
      return;
    }

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final identifier = _identifierController.text.trim();
    if (_loginMode == AuthLoginMode.code && _codeTarget != identifier) {
      ToastUtils.instance.show(context, '请先获取当前账号的验证码');
      return;
    }

    setState(() {
      _submitting = true;
    });

    try {
      final response = _loginMode == AuthLoginMode.password
          ? await widget.authApi.loginWithPassword(
              identifierType: _identifierType,
              identifier: identifier,
              password: _passwordController.text,
            )
          : await widget.authApi.loginWithCode(
              identifierType: _identifierType,
              identifier: identifier,
              code: _codeController.text.trim(),
            );

      final loginResult = response.result;
      if (loginResult.token.trim().isNotEmpty) {
        await tokenManager.setToken(loginResult.token.trim());
        if (loginResult.refreshToken.trim().isNotEmpty) {
          await tokenManager.setRefreshToken(loginResult.refreshToken.trim());
        }
      } else {
        await tokenManager.deleteToken();
      }

      await _userController.setUser(loginResult.user);
      final syncErrors = await sessionSyncService.syncForUser(
        loginResult.user.id,
      );

      if (!mounted) {
        return;
      }

      ToastUtils.instance.show(
        context,
        syncErrors.isEmpty
            ? (response.msg.isEmpty ? '登录成功' : response.msg)
            : '登录成功，但部分云端数据同步失败',
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.maybePop(context);
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      if (_loginMode == AuthLoginMode.code && e.code == 'NOT_REGISTERED') {
        final confirmed = await _showAutoRegisterDialog(e.message);
        if (!mounted || confirmed != true) {
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RegisterView(
              authApi: widget.authApi,
              initialIdentifierType: _identifierType,
              initialIdentifier: identifier,
              initialCode: _codeController.text.trim(),
            ),
          ),
        );
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

  Future<bool?> _showAutoRegisterDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('账号未注册'),
          content: Text(message.isEmpty ? '该账号尚未注册，是否前往注册？' : message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('去注册'),
            ),
          ],
        );
      },
    );
  }

  String _resolveAuthErrorMessage(ApiException error) {
    switch (error.code) {
      case 'CODE_INVALID':
        return '验证码错误，请检查后重试';
      case 'CODE_EXPIRED':
        return '验证码已过期，请重新获取';
      case 'CODE_REQUIRED':
        return '请输入验证码';
      case 'IDENTIFIER_EXISTS':
        return '该账号已注册，请直接登录';
      case 'CODE_SEND_TOO_FREQUENT':
        return '发送过于频繁，请稍后再试';
      case 'INVALID_IDENTIFIER':
      case 'INVALID_TARGET':
        return _identifierType == AuthIdentifierType.phone
            ? '手机号格式不正确'
            : '邮箱地址格式错误';
      default:
        return error.message.trim().isEmpty ? '请求失败，请稍后重试' : error.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      children: [
        _buildTopBar(),
        const SizedBox(height: 10),
        AuthHeroCard(
          palette: SoftBannerPalettes.authOf(context),
          icon: Icons.health_and_safety_rounded,
          title: '健康助手',
          subtitle:
              '${_identifierType.label}${_loginMode == AuthLoginMode.password ? '密码登录' : '验证码登录'}',
        ),
        const SizedBox(height: 10),
        AuthMethodSwitcher(
          items: [
            AuthMethodItem(
              label: AuthLoginMode.password.label,
              selected: _loginMode == AuthLoginMode.password,
              onTap: () => _onLoginModeChanged(AuthLoginMode.password),
            ),
            AuthMethodItem(
              label: AuthLoginMode.code.label,
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
        const Spacer(),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RegisterView(
                  authApi: widget.authApi,
                  initialIdentifierType: _identifierType,
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
          child: const Text('注册'),
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
                  labelText: _identifierType.label,
                  hintText: _identifierType == AuthIdentifierType.phone
                      ? '请输入手机号'
                      : '请输入邮箱地址',
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
              if (_loginMode == AuthLoginMode.password)
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  decoration: _buildInputDecoration(
                    labelText: '密码',
                    hintText: '6-12位字母或数字',
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
              labelText: '验证码',
              hintText: '请输入6位验证码',
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
                      : '发送',
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
        TextButton(
          onPressed: _toggleIdentifierType,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: scheme.primary,
          ),
          child: Text(_identifierType.alternateActionText),
        ),
        const Spacer(),
        TextButton(
          onPressed: _onTapForgotPassword,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: scheme.primary,
          ),
          child: const Text('找回密码'),
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

  Widget _buildLoginButton() {
    return SizedBox(
      height: 46,
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
            : const Text(
                '登录',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      _loginMode == AuthLoginMode.password
          ? '支持手机号或邮箱搭配密码登录。'
          : '支持手机号或邮箱验证码登录，未注册可直接去注册。',
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

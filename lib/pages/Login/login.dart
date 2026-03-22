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
  String _codeId = '';
  String _codeTarget = '';

  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  @override
  void dispose() {
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

  void _onTapAgreement() {
    ToastUtils.instance.show(context, '功能开发中');
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
    _codeId = '';
    _codeTarget = '';
    if (clearInput) {
      _codeController.clear();
    }
  }

  Future<void> _onSendCode() async {
    FocusScope.of(context).unfocus();
    if (_sendingCode) {
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
        _codeId = response.result.id.trim();
        _codeTarget = identifier;
      });
      ToastUtils.instance.show(
        context,
        response.msg.isEmpty ? '验证码发送成功' : response.msg,
      );
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
    if (_loginMode == AuthLoginMode.code &&
        (_codeId.isEmpty || _codeTarget != identifier)) {
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
              codeId: _codeId,
            );

      final loginResult = response.result;
      if (loginResult.token.trim().isNotEmpty) {
        await tokenManager.setToken(loginResult.token.trim());
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
              initialCodeId: _codeId,
            ),
          ),
        );
        return;
      }
      ToastUtils.instance.showError(context, e);
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

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      children: [
        _buildTopBar(),
        const SizedBox(height: 14),
        AuthHeroCard(
          palette: SoftBannerPalettes.auth,
          icon: Icons.health_and_safety_rounded,
          title: '健康助手',
          subtitle:
              '${_identifierType.label}${_loginMode == AuthLoginMode.password ? '密码登录' : '验证码登录'}',
        ),
        const SizedBox(height: 12),
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
        const SizedBox(height: 18),
        _buildFormCard(),
        const SizedBox(height: 18),
        _buildLoginButton(),
        const SizedBox(height: 10),
        _buildHelperText(),
      ],
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: Color(0xFF0F172A),
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
            minimumSize: const Size(56, 34),
            foregroundColor: const Color(0xFF0369A1),
            textStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: const Text('注册'),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                  final hasActiveCodeSession =
                      _codeId.isNotEmpty || _codeTarget.isNotEmpty;
                  if (hasActiveCodeSession && identifier != _codeTarget) {
                    setState(() {
                      _clearCodeSession(clearInput: false);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 6),
              _buildActionLinks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeRow() {
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
          onPressed: _sendingCode ? null : _onSendCode,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            minimumSize: const Size(96, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
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
              : const Text('发送验证码'),
        ),
      ],
    );
  }

  Widget _buildActionLinks() {
    return Row(
      children: [
        TextButton(
          onPressed: _toggleIdentifierType,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: const Color(0xFF0EA5E9),
          ),
          child: Text(_identifierType.alternateActionText),
        ),
        const Spacer(),
        TextButton(
          onPressed: _onTapAgreement,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: const Color(0xFF0EA5E9),
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
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 48,
      child: FilledButton(
        onPressed: _submitting ? null : _onLoginPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0EA5E9),
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
            : const Text(
                '登录',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Text(
      _loginMode == AuthLoginMode.password
          ? '支持手机号或邮箱搭配密码登录。'
          : '支持手机号或邮箱接收验证码登录；未注册时可直接跳转注册。',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/core/local_storage/token_manager.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';

/// 登录业务逻辑 provider。
final loginNotifierProvider =
    NotifierProvider<LoginNotifier, LoginFormState>(LoginNotifier.new);

class LoginFormState {
  final bool sendingCode;
  final bool submitting;
  final int codeCountdownSeconds;

  const LoginFormState({
    this.sendingCode = false,
    this.submitting = false,
    this.codeCountdownSeconds = 0,
  });

  LoginFormState copyWith({
    bool? sendingCode,
    bool? submitting,
    int? codeCountdownSeconds,
  }) {
    return LoginFormState(
      sendingCode: sendingCode ?? this.sendingCode,
      submitting: submitting ?? this.submitting,
      codeCountdownSeconds: codeCountdownSeconds ?? this.codeCountdownSeconds,
    );
  }
}

class LoginNotifier extends Notifier<LoginFormState> {
  static const _codeCooldownSeconds = 60;
  static final _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final _codeRegExp = RegExp(r'^\d{6}$');
  static final _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  Timer? _countdownTimer;
  String _codeTarget = '';

  String get codeTarget => _codeTarget;

  @override
  LoginFormState build() => const LoginFormState();

  String? validateIdentifier(String value, AuthIdentifierType type) {
    final v = value.trim();
    if (v.isEmpty) return type == AuthIdentifierType.phone ? '请输入手机号' : '请输入邮箱';
    if (type == AuthIdentifierType.phone && !_phoneRegExp.hasMatch(v)) return '手机号格式不正确';
    if (type == AuthIdentifierType.email && !_emailRegExp.hasMatch(v)) return '邮箱格式不正确';
    return null;
  }

  String? validatePassword(String value) {
    if (value.isEmpty) return '请输入密码';
    if (!_passwordRegExp.hasMatch(value)) return '密码为6-12位字母或数字';
    return null;
  }

  String? validateCode(String value) {
    final code = value.trim();
    if (code.isEmpty) return '请输入验证码';
    if (!_codeRegExp.hasMatch(code)) return '验证码为6位数字';
    return null;
  }

  void onIdentifierChanged(String value) {
    final id = value.trim();
    if (_codeTarget.isNotEmpty && id != _codeTarget) {
      _clearCodeSession();
    }
  }

  void _clearCodeSession() {
    _countdownTimer?.cancel();
    _codeTarget = '';
    state = state.copyWith(codeCountdownSeconds: 0);
  }

  Future<bool> sendCode({
    required String identifier,
    required AuthIdentifierType type,
    required AuthApi authApi,
  }) async {
    if (state.sendingCode || state.codeCountdownSeconds > 0) return false;

    state = state.copyWith(sendingCode: true);

    try {
      if (type == AuthIdentifierType.phone) {
        await authApi.sendPhoneCode(phone: identifier, scene: AuthCodeScene.login);
      } else {
        await authApi.sendEmailCode(email: identifier, scene: AuthCodeScene.login);
      }

      _codeTarget = identifier;
      _startCountdown();
      return true;
    } finally {
      state = state.copyWith(sendingCode: false);
    }
  }

  /// 执行登录 API 调用并保存 token，返回 [LoginResult]。
  /// 失败时抛出异常，由页面处理 toast。
  Future<LoginResult> login({
    required AuthIdentifierType type,
    required String identifier,
    required String password,
    required String code,
    required AuthLoginMode mode,
  }) async {
    if (state.submitting) throw StateError('Already submitting');
    state = state.copyWith(submitting: true);

    try {
      final response = mode == AuthLoginMode.password
          ? await authApi.loginWithPassword(
              identifierType: type,
              identifier: identifier.trim(),
              password: password,
            )
          : await authApi.loginWithCode(
              identifierType: type,
              identifier: identifier.trim(),
              code: code.trim(),
            );

      final result = response.result;
      if (result.token.trim().isNotEmpty) {
        await tokenManager.setToken(result.token.trim());
        if (result.refreshToken.trim().isNotEmpty) {
          await tokenManager.setRefreshToken(result.refreshToken.trim());
        }
      }
      return result;
    } finally {
      state = state.copyWith(submitting: false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    state = state.copyWith(codeCountdownSeconds: _codeCooldownSeconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.codeCountdownSeconds - 1;
      if (next <= 0) {
        timer.cancel();
        state = state.copyWith(codeCountdownSeconds: 0);
      } else {
        state = state.copyWith(codeCountdownSeconds: next);
      }
    });
  }
}

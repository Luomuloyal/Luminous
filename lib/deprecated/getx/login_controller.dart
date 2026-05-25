import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/register/presentation/register.dart';
import 'package:luminous/features/auth/data/session_sync_service.dart';
import 'package:luminous/core/local_storage/token_manager.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/features/auth/presentation/models/auth.dart';

/// 登录页页面级控制器。
///
/// 负责管理登录表单、验证码冷却、登录请求与登录后同步链路。
class LoginController extends GetxController {
  LoginController({required this.authApi, required this.onLoginSuccess});

  final Future<void> Function(UserSafe user) onLoginSuccess;

  static const int _codeCooldownSeconds = 60;
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');

  final AuthApi authApi;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  final AuthIdentifierType _identifierType = AuthIdentifierType.email;
  AuthLoginMode _loginMode = AuthLoginMode.password;
  bool _obscurePassword = true;
  bool _sendingCode = false;
  bool _submitting = false;
  String _codeTarget = '';
  Timer? _codeCountdownTimer;
  int _codeCountdownSeconds = 0;

  AuthIdentifierType get identifierType => _identifierType;
  AuthLoginMode get loginMode => _loginMode;
  bool get obscurePassword => _obscurePassword;
  bool get sendingCode => _sendingCode;
  bool get submitting => _submitting;
  String get codeTarget => _codeTarget;
  int get codeCountdownSeconds => _codeCountdownSeconds;

  @override
  void onClose() {
    _codeCountdownTimer?.cancel();
    identifierController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.onClose();
  }

  String identifierLabel(AppLocalizations l10n, AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? l10n.authPhoneLabel
        : l10n.authEmailLabel;
  }

  String loginModeLabel(AppLocalizations l10n, AuthLoginMode mode) {
    return mode == AuthLoginMode.password
        ? l10n.authPasswordLoginMode
        : l10n.authCodeLoginMode;
  }

  String? identifierValidator(AppLocalizations l10n, String? value) {
    final identifier = (value ?? '').trim();
    if (identifier.isEmpty) {
      return _identifierType == AuthIdentifierType.phone
          ? l10n.authValidationEnterPhone
          : l10n.authValidationEnterEmail;
    }
    if (_identifierType == AuthIdentifierType.phone &&
        !_phoneRegExp.hasMatch(identifier)) {
      return l10n.authValidationInvalidPhone;
    }
    if (_identifierType == AuthIdentifierType.email &&
        !_emailRegExp.hasMatch(identifier)) {
      return l10n.authValidationInvalidEmail;
    }
    return null;
  }

  String? passwordValidator(AppLocalizations l10n, String? value) {
    final pwd = value ?? '';
    if (pwd.isEmpty) {
      return l10n.authValidationEnterPassword;
    }
    if (!_passwordRegExp.hasMatch(pwd)) {
      return l10n.authValidationPasswordRule;
    }
    return null;
  }

  String? codeValidator(AppLocalizations l10n, String? value) {
    final code = (value ?? '').trim();
    if (code.isEmpty) {
      return l10n.authValidationEnterCode;
    }
    if (!_codeRegExp.hasMatch(code)) {
      return l10n.authValidationCodeRule;
    }
    return null;
  }

  void onTapForgotPassword(BuildContext context, AppLocalizations l10n) {
    ToastUtils.instance.show(context, l10n.loginForgotPasswordPending);
  }

  void onLoginModeChanged(BuildContext context, AuthLoginMode mode) {
    if (_submitting) {
      return;
    }
    FocusScope.of(context).unfocus();
    _loginMode = mode;
    _clearCodeSession(clearInput: true);
    update();
  }

  void onIdentifierChanged(String value) {
    final identifier = value.trim();
    final hasActiveCodeSession = _codeTarget.isNotEmpty;
    if (hasActiveCodeSession && identifier != _codeTarget) {
      _clearCodeSession(clearInput: false);
      update();
    }
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    update();
  }

  Future<void> onSendCode(BuildContext context, AppLocalizations l10n) async {
    FocusScope.of(context).unfocus();
    if (_sendingCode || _codeCountdownSeconds > 0) {
      return;
    }

    final identifier = identifierController.text.trim();
    final error = identifierValidator(l10n, identifier);
    if (error != null) {
      _showToast(context, error);
      return;
    }

    _sendingCode = true;
    update();

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await authApi.sendPhoneCode(
              phone: identifier,
              scene: AuthCodeScene.login,
            )
          : await authApi.sendEmailCode(
              email: identifier,
              scene: AuthCodeScene.login,
            );

      if (!context.mounted || isClosed) {
        return;
      }

      _codeTarget = identifier;
      update();
      _startCodeCooldown();
      _showToast(
        context,
        response.msg.isEmpty ? l10n.authCodeSentSuccess : response.msg,
      );
    } on ApiException catch (e) {
      if (!context.mounted || isClosed) {
        return;
      }
      _showToast(context, _resolveAuthErrorMessage(l10n, e));
    } catch (e) {
      if (!context.mounted || isClosed) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (!isClosed) {
        _sendingCode = false;
        update();
      }
    }
  }

  Future<void> onLoginPressed(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    FocusScope.of(context).unfocus();
    if (_submitting) {
      return;
    }

    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    final identifier = identifierController.text.trim();
    if (_loginMode == AuthLoginMode.code && _codeTarget != identifier) {
      _showToast(context, l10n.loginNeedCodeForCurrentAccount);
      return;
    }

    _submitting = true;
    update();

    try {
      final response = _loginMode == AuthLoginMode.password
          ? await authApi.loginWithPassword(
              identifierType: _identifierType,
              identifier: identifier,
              password: passwordController.text,
            )
          : await authApi.loginWithCode(
              identifierType: _identifierType,
              identifier: identifier,
              code: codeController.text.trim(),
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

      await onLoginSuccess(loginResult.user);
      final syncErrors = await sessionSyncService.syncForUser(
        loginResult.user.id,
      );

      if (!context.mounted || isClosed) {
        return;
      }

      _showToast(
        context,
        syncErrors.isEmpty
            ? (response.msg.isEmpty ? l10n.loginSuccess : response.msg)
            : l10n.loginSuccessPartialSync,
      );

      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (!context.mounted || isClosed) {
        return;
      }
      Navigator.maybePop(context);
    } on ApiException catch (e) {
      if (!context.mounted || isClosed) {
        return;
      }
      if (_loginMode == AuthLoginMode.code && e.code == 'NOT_REGISTERED') {
        final confirmed = await _showAutoRegisterDialog(
          context,
          l10n,
          e.message,
        );
        if (!context.mounted || isClosed || confirmed != true) {
          return;
        }
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => RegisterPage(
              authApi: authApi,
              initialIdentifierType: _identifierType,
              initialIdentifier: identifier,
              initialCode: codeController.text.trim(),
            ),
          ),
        );
        return;
      }
      _showToast(context, _resolveAuthErrorMessage(l10n, e));
    } catch (e) {
      if (!context.mounted || isClosed) {
        return;
      }
      ToastUtils.instance.showError(context, e);
    } finally {
      if (!isClosed) {
        _submitting = false;
        update();
      }
    }
  }

  Future<bool?> _showAutoRegisterDialog(
    BuildContext context,
    AppLocalizations l10n,
    String message,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.loginAutoRegisterTitle),
          content: Text(
            message.isEmpty ? l10n.loginAutoRegisterPrompt : message,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.loginAutoRegisterCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.loginAutoRegisterConfirm),
            ),
          ],
        );
      },
    );
  }

  String _resolveAuthErrorMessage(AppLocalizations l10n, ApiException error) {
    switch (error.code) {
      case 'CODE_INVALID':
        return l10n.authErrorCodeInvalid;
      case 'CODE_EXPIRED':
        return l10n.authErrorCodeExpired;
      case 'CODE_REQUIRED':
        return l10n.authErrorCodeRequired;
      case 'IDENTIFIER_EXISTS':
        return l10n.authErrorIdentifierExistsLogin;
      case 'CODE_SEND_TOO_FREQUENT':
        return l10n.authErrorTooFrequent;
      case 'INVALID_IDENTIFIER':
      case 'INVALID_TARGET':
        return _identifierType == AuthIdentifierType.phone
            ? l10n.authErrorInvalidPhone
            : l10n.authErrorInvalidEmailFormat;
      default:
        return error.message.trim().isEmpty
            ? l10n.authErrorRequestFailed
            : error.message;
    }
  }

  void _clearCodeSession({required bool clearInput}) {
    _resetCodeCooldown();
    _codeTarget = '';
    if (clearInput) {
      codeController.clear();
    }
  }

  void _startCodeCooldown() {
    _codeCountdownTimer?.cancel();
    _codeCountdownSeconds = _codeCooldownSeconds;
    update();
    _codeCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      if (_codeCountdownSeconds <= 1) {
        timer.cancel();
        _codeCountdownSeconds = 0;
        update();
        return;
      }
      _codeCountdownSeconds -= 1;
      update();
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

  void _showToast(BuildContext context, String message) {
    ToastUtils.instance.show(context, message);
  }
}

// The public constructor keeps non-private named parameters for callers.
// ignore_for_file: prefer_initializing_formals

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/api/auth_api.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 注册页页面级控制器。
///
/// 负责管理注册表单、验证码冷却、协议勾选与注册请求流程。
class RegisterController extends GetxController {
  RegisterController({
    required this.authApi,
    required AuthIdentifierType initialIdentifierType,
    required String initialIdentifier,
    required String initialCode,
  }) : _identifierType = initialIdentifierType,
       _initialIdentifier = initialIdentifier,
       _initialCode = initialCode;

  static const int _codeCooldownSeconds = 60;
  static final RegExp _emailRegExp = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final RegExp _phoneRegExp = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _codeRegExp = RegExp(r'^\d{6}$');
  static final RegExp _passwordRegExp = RegExp(r'^[A-Za-z0-9]{6,12}$');
  static final RegExp _usernameRegExp = RegExp(r'^\S{2,30}$');

  final AuthApi authApi;
  final AuthIdentifierType _identifierType;
  final String _initialIdentifier;
  final String _initialCode;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _agreed = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _sendingCode = false;
  bool _submitting = false;
  String _codeTarget = '';
  Timer? _codeCountdownTimer;
  int _codeCountdownSeconds = 0;

  AuthIdentifierType get identifierType => _identifierType;
  bool get agreed => _agreed;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirm => _obscureConfirm;
  bool get sendingCode => _sendingCode;
  bool get submitting => _submitting;
  String get codeTarget => _codeTarget;
  int get codeCountdownSeconds => _codeCountdownSeconds;

  @override
  void onInit() {
    super.onInit();
    identifierController.text = _initialIdentifier;
    codeController.text = _initialCode;
    final initialCode = _initialCode.trim();
    _codeTarget = initialCode.isEmpty ? '' : _initialIdentifier.trim();
  }

  @override
  void onClose() {
    _codeCountdownTimer?.cancel();
    identifierController.dispose();
    usernameController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  String identifierLabel(AppLocalizations l10n, AuthIdentifierType type) {
    return type == AuthIdentifierType.phone
        ? l10n.authPhoneLabel
        : l10n.authEmailLabel;
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

  String? usernameValidator(AppLocalizations l10n, String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) {
      return null;
    }
    if (!_usernameRegExp.hasMatch(username)) {
      return l10n.registerUsernameValidation;
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

  String? confirmValidator(AppLocalizations l10n, String? value) {
    final confirm = value ?? '';
    if (confirm.isEmpty) {
      return l10n.authValidationEnterConfirmPassword;
    }
    if (confirm != passwordController.text) {
      return l10n.authValidationPasswordMismatch;
    }
    return null;
  }

  void onIdentifierChanged(String value) {
    final identifier = value.trim();
    final hasActiveCodeSession = _codeTarget.isNotEmpty;
    if (hasActiveCodeSession && identifier != _codeTarget) {
      _clearCodeSession(clearInput: false);
      update();
    }
  }

  void setAgreed(bool value) {
    if (_agreed == value) {
      return;
    }
    _agreed = value;
    update();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    update();
  }

  void toggleObscureConfirm() {
    _obscureConfirm = !_obscureConfirm;
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
              scene: AuthCodeScene.register,
            )
          : await authApi.sendEmailCode(
              email: identifier,
              scene: AuthCodeScene.register,
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

  Future<void> onRegisterPressed(
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
    final username = usernameController.text.trim();
    if (_codeTarget != identifier) {
      _showToast(context, l10n.registerNeedCodeForCurrentAccount);
      return;
    }
    if (!_agreed) {
      _showToast(context, l10n.registerNeedAgreement);
      return;
    }

    _submitting = true;
    update();

    try {
      final response = _identifierType == AuthIdentifierType.phone
          ? await authApi.registerWithPhone(
              phone: identifier,
              code: codeController.text.trim(),
              password: passwordController.text,
              username: username,
            )
          : await authApi.registerWithEmail(
              email: identifier,
              code: codeController.text.trim(),
              password: passwordController.text,
              username: username,
            );

      if (!context.mounted || isClosed) {
        return;
      }

      _showToast(
        context,
        response.msg.isEmpty ? l10n.registerSuccess : response.msg,
      );
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!context.mounted || isClosed) {
        return;
      }
      Navigator.maybePop(context);
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
        _submitting = false;
        update();
      }
    }
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
        return _identifierType == AuthIdentifierType.phone
            ? l10n.authErrorIdentifierExistsPhoneRegistered
            : l10n.authErrorIdentifierExistsEmailRegistered;
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

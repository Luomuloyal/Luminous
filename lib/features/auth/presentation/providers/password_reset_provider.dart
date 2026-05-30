import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';

class PasswordResetState {
  const PasswordResetState({
    this.email = '',
    this.code = '',
    this.password = '',
    this.isSubmitting = false,
    this.cooldownSeconds,
    this.errorMessage,
    this.successMessage,
  });

  final String email;
  final String code;
  final String password;
  final bool isSubmitting;
  final int? cooldownSeconds;
  final String? errorMessage;
  final String? successMessage;

  PasswordResetState copyWith({
    String? email,
    String? code,
    String? password,
    bool? isSubmitting,
    int? cooldownSeconds,
    String? errorMessage,
    String? successMessage,
    bool clearCooldown = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return PasswordResetState(
      email: email ?? this.email,
      code: code ?? this.code,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      cooldownSeconds: clearCooldown
          ? null
          : cooldownSeconds ?? this.cooldownSeconds,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}

class PasswordResetNotifier extends Notifier<PasswordResetState> {
  @override
  PasswordResetState build() => const PasswordResetState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, clearErrorMessage: true);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, clearErrorMessage: true);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, clearErrorMessage: true);
  }

  Future<bool> sendResetCode() async {
    state = state.copyWith(
      isSubmitting: true,
      clearCooldown: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .forgotPassword(email: state.email);
      state = state.copyWith(
        isSubmitting: false,
        cooldownSeconds: result.cooldown.toInt(),
        successMessage: result.message,
      );
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<bool> resetPassword() async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    try {
      await ref
          .read(authRemoteDataSourceProvider)
          .resetPassword(
            email: state.email,
            code: state.code,
            password: state.password,
          );
      state = state.copyWith(isSubmitting: false, successMessage: '');
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  bool _fail(Object error) {
    final apiError = LucentErrorMapper.fromObject(error);
    state = state.copyWith(
      isSubmitting: false,
      errorMessage: apiError.message,
      clearSuccessMessage: true,
    );
    return false;
  }
}

final passwordResetProvider =
    NotifierProvider<PasswordResetNotifier, PasswordResetState>(
      PasswordResetNotifier.new,
    );

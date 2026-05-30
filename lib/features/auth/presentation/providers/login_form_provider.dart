import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

enum AuthLoginMode { password, code }

class LoginFormState {
  const LoginFormState({
    this.email = '',
    this.password = '',
    this.code = '',
    this.mode = AuthLoginMode.password,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final String code;
  final AuthLoginMode mode;
  final bool isSubmitting;
  final String? errorMessage;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? code,
    AuthLoginMode? mode,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      code: code ?? this.code,
      mode: mode ?? this.mode,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class LoginFormNotifier extends Notifier<LoginFormState> {
  @override
  LoginFormState build() => const LoginFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, clearErrorMessage: true);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, clearErrorMessage: true);
  }

  void updateCode(String value) {
    state = state.copyWith(code: value, clearErrorMessage: true);
  }

  void updateMode(AuthLoginMode mode) {
    state = state.copyWith(mode: mode, clearErrorMessage: true);
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      final session = await ref.read(authRemoteDataSourceProvider).login(
        email: state.email,
        password: state.mode == AuthLoginMode.password ? state.password : null,
        code: state.mode == AuthLoginMode.code ? state.code : null,
      );
      await ref.read(authSessionProvider.notifier).applySession(session);
      state = state.copyWith(isSubmitting: false);
      return session;
    } on LucentApiException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: error.message,
      );
      return null;
    }
  }

  Future<CooldownMessageDto?> sendCode() async {
    try {
      return await ref.read(authRemoteDataSourceProvider).sendVerificationCode(
        email: state.email,
        scene: AuthVerificationScene.login,
      );
    } on LucentApiException catch (error) {
      state = state.copyWith(errorMessage: error.message);
      return null;
    }
  }
}

final loginFormProvider =
    NotifierProvider<LoginFormNotifier, LoginFormState>(LoginFormNotifier.new);

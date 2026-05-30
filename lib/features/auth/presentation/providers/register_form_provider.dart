import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

class RegisterFormState {
  const RegisterFormState({
    this.email = '',
    this.password = '',
    this.nickname = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  final String email;
  final String password;
  final String nickname;
  final bool isSubmitting;
  final String? errorMessage;

  RegisterFormState copyWith({
    String? email,
    String? password,
    String? nickname,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return RegisterFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      nickname: nickname ?? this.nickname,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  @override
  RegisterFormState build() => const RegisterFormState();

  void updateEmail(String value) {
    state = state.copyWith(email: value, clearErrorMessage: true);
  }

  void updatePassword(String value) {
    state = state.copyWith(password: value, clearErrorMessage: true);
  }

  void updateNickname(String value) {
    state = state.copyWith(nickname: value, clearErrorMessage: true);
  }

  Future<AuthSession?> submit() async {
    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    try {
      final session = await ref.read(authRemoteDataSourceProvider).register(
        email: state.email,
        password: state.password,
        nickname: state.nickname,
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
}

final registerFormProvider = NotifierProvider<
  RegisterFormNotifier,
  RegisterFormState
>(RegisterFormNotifier.new);

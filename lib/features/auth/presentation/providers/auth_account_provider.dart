import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

class AuthAccountState {
  const AuthAccountState({
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.lastCooldownSeconds,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final int? lastCooldownSeconds;

  AuthAccountState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    int? lastCooldownSeconds,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
    bool clearCooldown = false,
  }) {
    return AuthAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
      lastCooldownSeconds: clearCooldown
          ? null
          : lastCooldownSeconds ?? this.lastCooldownSeconds,
    );
  }
}

class AuthAccountNotifier extends Notifier<AuthAccountState> {
  @override
  AuthAccountState build() => const AuthAccountState();

  Future<bool> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
      clearCooldown: true,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(email: email, scene: scene);
      state = state.copyWith(
        isSubmitting: false,
        successMessage: result.message,
        lastCooldownSeconds: result.cooldown.toInt(),
      );
      return true;
    } catch (error) {
      return _fail(error);
    }
  }

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .verifyEmail(email: email, code: code);
      final currentUser = ref.read(authSessionProvider).user;
      if (currentUser != null && currentUser.email == email.trim()) {
        ref
            .read(authSessionProvider.notifier)
            .applyUser(currentUser.copyWith(emailVerified: true));
      }
    });
  }

  Future<bool> updateProfile({String? nickname, String? avatar}) async {
    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .updateMe(nickname: nickname, avatar: avatar);
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> changeEmail({
    required String newEmail,
    required String code,
  }) async {
    final currentUser = ref.read(authSessionProvider).user;
    if (currentUser == null) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Not signed in.',
        clearSuccessMessage: true,
      );
      return false;
    }

    return _run(() async {
      final user = await ref
          .read(authRemoteDataSourceProvider)
          .changeEmail(
            newEmail: newEmail,
            code: code,
            currentUser: currentUser,
          );
      ref.read(authSessionProvider.notifier).applyUser(user);
    });
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .changePassword(oldPassword: oldPassword, newPassword: newPassword);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> deleteAccount({required String password}) async {
    return _run(() async {
      await ref
          .read(authRemoteDataSourceProvider)
          .deleteAccount(password: password);
      ref.read(authSessionProvider.notifier).clearLocalSession();
    });
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    try {
      await action();
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

final authAccountProvider =
    NotifierProvider<AuthAccountNotifier, AuthAccountState>(
      AuthAccountNotifier.new,
    );

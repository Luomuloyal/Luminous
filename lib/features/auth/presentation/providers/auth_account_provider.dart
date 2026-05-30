import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';

part 'auth_account_provider.freezed.dart';

@freezed
abstract class AuthAccountState with _$AuthAccountState {
  const factory AuthAccountState({
    @Default(false) bool isSubmitting,
    @Default(false) bool isSendingCode,
    String? errorMessage,
    String? successMessage,
    int? lastCooldownSeconds,
  }) = _AuthAccountState;
}

class AuthAccountNotifier extends Notifier<AuthAccountState> {
  @override
  AuthAccountState build() => const AuthAccountState();

  Future<bool> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    state = state.copyWith(
      isSendingCode: true,
      errorMessage: null,
      successMessage: null,
      lastCooldownSeconds: null,
    );
    try {
      final result = await ref
          .read(authRemoteDataSourceProvider)
          .sendVerificationCode(email: email, scene: scene);
      state = state.copyWith(
        isSendingCode: false,
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
        successMessage: null,
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
      errorMessage: null,
      successMessage: null,
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
      isSendingCode: false,
      errorMessage: apiError.message,
      successMessage: null,
    );
    return false;
  }
}

final authAccountProvider =
    NotifierProvider<AuthAccountNotifier, AuthAccountState>(
      AuthAccountNotifier.new,
    );

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/providers/auth_data_providers.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';

class AuthSessionState {
  const AuthSessionState({
    this.user,
    this.isLoading = false,
    this.isAuthenticated = false,
    this.errorMessage,
  });

  final AuthUser? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? errorMessage;

  AuthSessionState copyWith({
    AuthUser? user,
    bool? isLoading,
    bool? isAuthenticated,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthSessionState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthSessionNotifier extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() {
    return const AuthSessionState();
  }

  Future<void> restore() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      final token = await ref.read(lucentDioClientProvider).readAccessToken();
      if (token == null || token.isEmpty) {
        state = const AuthSessionState();
        return;
      }

      final user = await ref.read(authRemoteDataSourceProvider).fetchMe();
      state = AuthSessionState(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (error) {
      final apiError = LucentErrorMapper.fromObject(error);
      await ref.read(lucentDioClientProvider).clearSession();
      state = AuthSessionState(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: apiError.message,
      );
    }
  }

  Future<void> applySession(AuthSession session) async {
    state = AuthSessionState(
      user: session.user,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  void applyUser(AuthUser user) {
    state = state.copyWith(
      user: user,
      isAuthenticated: true,
      isLoading: false,
      clearErrorMessage: true,
    );
  }

  void clearLocalSession() {
    state = const AuthSessionState();
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    try {
      await ref.read(authRemoteDataSourceProvider).logout();
    } finally {
      state = const AuthSessionState();
    }
  }
}

final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
      AuthSessionNotifier.new,
    );

import 'dart:async';

import 'package:dio/dio.dart';

import 'package:luminous/constants/http_constants.dart' as h;
import 'package:luminous/constants/global_constants.dart' as g;
import 'package:luminous/core/local_storage/token_manager.dart';

/// Service responsible for refreshing expired access tokens.
///
/// Key behaviours:
/// - Uses a dedicated [Dio] instance to avoid intercept recursion.
/// - **Debounce**: concurrent 401s share a single in-flight refresh Future.
/// - On success: persists new tokens via [tokenManager].
/// - On failure: cleans tokens and invokes [onSessionExpired] callback
///   (typically to clear the user session provider and navigate to login).
class TokenRefreshService {
  final Dio _refreshDio;
  final TokenManager? _tokenManager;
  Future<bool>? _pendingRefresh;

  TokenManager get _tm => _tokenManager ?? tokenManager;
  void Function()? _onSessionExpired;

  /// For production use, pass [baseUrl] (creates a fresh Dio).
  /// For testing, pass [dio] and [tokenManagerOverride].
  TokenRefreshService({String? baseUrl, Dio? dio, TokenManager? tokenManagerOverride})
    : _refreshDio = dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? '')),
      _tokenManager = tokenManagerOverride;

  /// Register a callback invoked when the refresh token is no longer valid
  /// and the user session must be cleared.
  ///
  /// Called at most once per refresh-failure cascade thanks to debounce.
  void onSessionExpired(void Function() callback) {
    _onSessionExpired = callback;
  }

  // ── Refresh ────────────────────────────────────────────────────

  /// Attempt to refresh the access token using the stored refresh token.
  ///
  /// If a refresh is already in-flight, returns the same Future — concurrent
  /// 401s are debounced so that only one HTTP call is made and the session
  /// expiry callback fires at most once.
  ///
  /// Returns `true` if refresh succeeded and new tokens were persisted.
  Future<bool> refresh() async {
    if (_pendingRefresh != null) {
      return _pendingRefresh!;
    }

    _pendingRefresh = _doRefresh();
    try {
      return await _pendingRefresh!;
    } finally {
      _pendingRefresh = null;
    }
  }

  Future<bool> _doRefresh() async {
    final storedRefreshToken = await _tm.getRefreshToken();
    if (storedRefreshToken.isEmpty) {
      await _handleRefreshFailure();
      return false;
    }

    try {
      final response = await _refreshDio.post<dynamic>(
        h.HttpConstants.REFRESH_TOKEN,
        data: {'refreshToken': storedRefreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map &&
            data['code']?.toString() == g.GlobalConstants.SUCCESS_CODE) {
          final result = data['result'];
          final newAccessToken = result['accessToken'] as String? ?? '';
          final newRefreshToken = result['refreshToken'] as String? ?? '';

          if (newAccessToken.isNotEmpty && newRefreshToken.isNotEmpty) {
            await _tm.setToken(newAccessToken);
            await _tm.setRefreshToken(newRefreshToken);
            return true;
          }
        }
      }
    } on DioException catch (_) {
      // Network error, timeout, server 5xx → all treated as refresh failure
      // triggering session expiry. Non-Dio exceptions rethrow.
    }

    await _handleRefreshFailure();
    return false;
  }

  Future<void> _handleRefreshFailure() async {
    await _tm.deleteToken();
    _onSessionExpired?.call();
  }
}

/// Global singleton for the Dio interceptor and startup warmup.
///
/// Initialised during app startup with the correct base URL and
/// session-expiry hook wired to [UserSessionNotifier.clear].
TokenRefreshService? tokenRefreshService;

// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';
import 'package:luminous/core/network/lucent_api_exception.dart';
import 'package:luminous/core/network/lucent_envelope.dart';
import 'package:luminous/core/network/lucent_result_code.dart';
import 'package:luminous/core/network/lucent_session_store.dart';

/// Luminous 对 Lucent OpenAPI 客户端的统一封装入口。
///
/// 约定：
/// - 生成代码放在 `packages/lucent_openapi`
/// - 业务层不要直接 new 生成器里的 `LucentOpenapi`
/// - 统一通过这里注入 baseUrl、token 和通用 Dio 行为
class LucentDioClient {
  LucentDioClient({
    required String baseUrl,
    required LucentSessionStore sessionStore,
    Future<void> Function()? onSessionExpired,
    Dio? dio,
    Iterable<Interceptor> interceptors = const [],
  }) : _openapi = LucentOpenapi(
         dio: dio ??
             Dio(
               BaseOptions(
                 baseUrl: baseUrl,
                 connectTimeout: const Duration(seconds: 10),
                 receiveTimeout: const Duration(seconds: 10),
                 sendTimeout: const Duration(seconds: 10),
                 contentType: Headers.jsonContentType,
                 responseType: ResponseType.json,
               ),
             ),
         interceptors: <Interceptor>[],
       ),
       _sessionStore = sessionStore,
       _baseUrl = baseUrl,
       _onSessionExpired = onSessionExpired {
    _openapi.dio.interceptors.addAll(<Interceptor>[
      ...interceptors,
      ..._buildInterceptors(),
    ]);
  }

  final LucentOpenapi _openapi;
  final LucentSessionStore _sessionStore;
  final String _baseUrl;
  final Future<void> Function()? _onSessionExpired;
  late final Dio _refreshDio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );
  Future<LucentSessionTokens?>? _refreshFuture;

  List<Interceptor> _buildInterceptors() {
    return <Interceptor>[
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.putIfAbsent('Accept', () => 'application/json');

          final skipAuthorization = options.extra['skipAuthorization'] == true;
          final hasSecureRequirement =
              (options.extra['secure'] as List?)?.isNotEmpty ?? false;
          final alreadyHasAuthorization =
              options.headers.containsKey('Authorization');

          if (!skipAuthorization &&
              hasSecureRequirement &&
              !alreadyHasAuthorization) {
            final token = await _sessionStore.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (await _shouldRefresh(error)) {
            final refreshedTokens = await _refreshTokens();
            if (refreshedTokens != null && refreshedTokens.hasAccessToken) {
              final retryResponse = await _retry(error.requestOptions, refreshedTokens);
              handler.resolve(retryResponse);
              return;
            }

            await _sessionStore.clear();
            if (_onSessionExpired != null) {
              await _onSessionExpired();
            }
          }

          handler.reject(_mapToApiException(error));
        },
      ),
    ];
  }

  Dio get dio => _openapi.dio;

  AppApi get appApi => _openapi.getAppApi();

  AuthApi get authApi => _openapi.getAuthApi();

  Future<void> writeSession(LucentSessionTokens tokens) {
    return _sessionStore.write(tokens);
  }

  Future<void> clearSession() {
    return _sessionStore.clear();
  }

  void dispose() {
    _openapi.dio.close(force: true);
    _refreshDio.close(force: true);
  }

  Future<bool> _shouldRefresh(DioException error) async {
    final requestOptions = error.requestOptions;
    if (requestOptions.extra['skipAuthRefresh'] == true) {
      return false;
    }

    if (requestOptions.extra['hasRetriedAfterRefresh'] == true) {
      return false;
    }

    final statusCode = error.response?.statusCode;
    if (statusCode != 401) {
      return false;
    }

    final data = error.response?.data;
    final json = _coerceToMap(data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final code = envelope?.code;

    if (code == LucentResultCode.tokenExpired) {
      final refreshToken = await _sessionStore.readRefreshToken();
      return refreshToken != null && refreshToken.isNotEmpty;
    }

    return false;
  }

  Future<LucentSessionTokens?> _refreshTokens() {
    final pending = _refreshFuture;
    if (pending != null) {
      return pending;
    }

    final future = _doRefresh();
    _refreshFuture = future;
    future.whenComplete(() => _refreshFuture = null);
    return future;
  }

  Future<LucentSessionTokens?> _doRefresh() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Object>(
        '/api/v1/auth/refresh',
        data: <String, String>{'refreshToken': refreshToken},
        options: Options(
          extra: const <String, Object?>{
            'skipAuthorization': true,
            'skipAuthRefresh': true,
          },
        ),
      );

      final json = _coerceToMap(response.data);
      if (json == null) {
        throw const LucentApiException(
          message: 'Lucent refresh response is empty.',
        );
      }

      final envelope = LucentEnvelope<LucentSessionTokens>.fromJson(
        json,
        dataDecoder: (raw) {
          final dataMap = _coerceToMap(raw) ?? const <String, dynamic>{};
          final accessToken = dataMap['accessToken']?.toString().trim() ?? '';
          final nextRefreshToken =
              dataMap['refreshToken']?.toString().trim() ?? '';
          return LucentSessionTokens(
            accessToken: accessToken,
            refreshToken: nextRefreshToken,
          );
        },
      );

      if (!envelope.isSuccess || envelope.data == null) {
        throw LucentApiException(
          message: envelope.message.isNotEmpty
              ? envelope.message
              : 'Lucent refresh failed.',
          code: envelope.code,
          statusCode: response.statusCode,
        );
      }

      await _sessionStore.write(envelope.data!);
      return envelope.data;
    } on DioException catch (error) {
      throw _mapToApiException(error);
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions requestOptions,
    LucentSessionTokens tokens,
  ) {
    final nextHeaders = Map<String, dynamic>.from(requestOptions.headers);
    nextHeaders['Authorization'] = 'Bearer ${tokens.accessToken}';

    final nextExtra = Map<String, dynamic>.from(requestOptions.extra);
    nextExtra['hasRetriedAfterRefresh'] = true;

    return _openapi.dio.fetch<dynamic>(
      requestOptions.copyWith(
        headers: nextHeaders,
        extra: nextExtra,
      ),
    );
  }

  DioException _mapToApiException(DioException error) {
    final response = error.response;
    final json = _coerceToMap(response?.data);
    final envelope = json == null
        ? null
        : LucentEnvelope<Object?>.fromJson(json, dataDecoder: (raw) => raw);
    final requestId = response?.headers.value('X-Request-Id');

    return DioException(
      requestOptions: error.requestOptions,
      response: response,
      type: error.type,
      error: LucentApiException(
        message: envelope?.message.isNotEmpty == true
            ? envelope!.message
            : _fallbackMessage(error),
        code: envelope?.code,
        statusCode: response?.statusCode,
        requestId: requestId,
        data: json,
      ),
      stackTrace: error.stackTrace,
    );
  }

  String _fallbackMessage(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out.',
      DioExceptionType.sendTimeout => 'Request send timed out.',
      DioExceptionType.receiveTimeout => 'Response receive timed out.',
      DioExceptionType.badCertificate => 'Bad server certificate.',
      DioExceptionType.connectionError => 'Network request failed.',
      DioExceptionType.cancel => 'Request was cancelled.',
      DioExceptionType.badResponse => 'Request failed.',
      DioExceptionType.unknown => 'Unexpected network error.',
    };
  }

  Map<String, dynamic>? _coerceToMap(Object? value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map(
        (key, entryValue) => MapEntry(key.toString(), entryValue),
      );
    }
    return null;
  }
}

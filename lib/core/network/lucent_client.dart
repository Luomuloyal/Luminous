import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/local_storage/token_manager.dart';
import 'package:luminous/core/network/api_exception.dart';

/// Lucent API 分页元信息。
class LucentPaginationMeta {
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  const LucentPaginationMeta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPages,
  });

  factory LucentPaginationMeta.fromJson(Map<String, dynamic> json) {
    return LucentPaginationMeta(
      page: (json['page'] as num?)?.toInt() ?? 1,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      total: (json['total'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Lucent API 响应级元信息。
///
/// 当前仅包含分页信息，后续可按需扩展。
class LucentResponseMeta {
  final LucentPaginationMeta? pagination;

  const LucentResponseMeta({this.pagination});

  factory LucentResponseMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LucentResponseMeta();
    return LucentResponseMeta(
      pagination: json['pagination'] != null
          ? LucentPaginationMeta.fromJson(
              json['pagination'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Lucent API 统一响应包装。
///
/// 对应 Lucent 后端 `{ code, message, data, meta? }` envelope。
class LucentApiResult<T> {
  /// 业务状态码，0 = 成功，非 0 = 失败。
  final int code;

  /// 人类可读提示信息。
  final String message;

  /// 经过 decoder 解析后的业务数据。
  final T data;

  /// 可选的响应级元信息（分页等）。
  final LucentResponseMeta? meta;

  const LucentApiResult({
    required this.code,
    required this.message,
    required this.data,
    this.meta,
  });

  /// 当前响应是否为成功状态。
  bool get isOk => code == GlobalConstants.LUCENT_SUCCESS_CODE;
}

/// Lucent `/api/v1` 网络客户端。
///
/// 只解析 Lucent `{ code, message, data, meta? }` envelope，
/// 不与旧 Express `{ code, msg, result }` 协议混用。
///
/// baseUrl 为 `domain/api`（[GlobalConstants.LUCENT_BASE_URL]），
/// 具体路径写 `/v1/xxx`。
///
/// 用法：
/// ```dart
/// final result = await lucentClient.get<Map<String, dynamic>>(
///   '/v1/health',
///   decoder: (json) => json as Map<String, dynamic>,
/// );
/// ```
class LucentApiClient {
  LucentApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: GlobalConstants.LUCENT_BASE_URL,
        connectTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        receiveTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        sendTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        responseType: ResponseType.json,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenManager.getToken();
          if (token.trim().isNotEmpty &&
              !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer ${token.trim()}';
          }
          if (kDebugMode) {
            debugPrint('[LUCENT][REQ] ${options.method} ${options.uri}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final requestId =
                response.headers.value('X-Request-Id') ?? '<none>';
            debugPrint(
              '[LUCENT][RES] ${response.statusCode} '
              '${response.requestOptions.uri} '
              'x-request-id=$requestId',
            );
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            debugPrint(
              '[LUCENT][ERR] ${error.requestOptions.uri} '
              'status=${error.response?.statusCode} '
              'msg=${error.message}',
            );
          }
          handler.reject(error);
        },
      ),
    );
  }

  /// 全局单例。
  static final LucentApiClient instance = LucentApiClient._internal();

  late final Dio _dio;

  /// 发起 GET 请求。
  Future<LucentApiResult<T>> get<T>(
    String path, {
    required T Function(dynamic json) decoder,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      'GET',
      path,
      decoder: decoder,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 发起 POST 请求。
  Future<LucentApiResult<T>> post<T>(
    String path, {
    required T Function(dynamic json) decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      'POST',
      path,
      decoder: decoder,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// 统一请求入口：解析 Lucent envelope 并转换为 [LucentApiResult]。
  Future<LucentApiResult<T>> _request<T>(
    String method,
    String path, {
    required T Function(dynamic json) decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final requestOptions = (options ?? Options()).copyWith(method: method);

      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      final rawData = _coerceToMap(response.data);

      final code = _parseCode(rawData['code']);
      final message = (rawData['message'] ?? '').toString();

      if (kDebugMode) {
        debugPrint(
          '[LUCENT][BIZ] code=$code '
          'message=${message.isEmpty ? '<empty>' : message} '
          'uri=${response.requestOptions.uri}',
        );
      }

      if (code != GlobalConstants.LUCENT_SUCCESS_CODE) {
        throw ApiException(
          message.isNotEmpty ? message : 'Request failed',
          code: code.toString(),
        );
      }

      return LucentApiResult<T>(
        code: code,
        message: message,
        data: decoder(rawData['data']),
        meta: rawData['meta'] != null
            ? LucentResponseMeta.fromJson(
                rawData['meta'] as Map<String, dynamic>,
              )
            : null,
      );
    } on DioException catch (e) {
      throw ApiException(_parseDioError(e));
    }
  }

  /// 将后端返回的 code 字段转为 int。
  ///
  /// 兼容后端返回 `int`（新协议）或 `String`（旧版 or debug）。
  static int _parseCode(dynamic codeValue) {
    if (codeValue is int) return codeValue;
    if (codeValue is num) return codeValue.toInt();
    if (codeValue is String) return int.tryParse(codeValue) ?? -1;
    return -1;
  }

  /// 将后端返回的动态数据转为 `Map<String, dynamic>`。
  Map<String, dynamic> _coerceToMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String) return _coerceToMap(jsonDecode(data));
    throw Exception('Unexpected response format: ${data.runtimeType}');
  }

  /// 将 Dio 异常转为人类可读消息。
  String _parseDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverData = error.response?.data;

    final serverMessage = _extractServerMessage(serverData);
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Network request timed out';
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        return 'Network request failed';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.badResponse:
        return _messageForStatusCode(statusCode);
      case DioExceptionType.unknown:
        return 'Network request failed';
    }
  }

  String? _extractServerMessage(dynamic serverData) {
    if (serverData is Map<String, dynamic>) {
      return serverData['message']?.toString() ??
          serverData['msg']?.toString() ??
          serverData['error']?.toString();
    }
    if (serverData is Map) {
      return serverData['message']?.toString() ??
          serverData['msg']?.toString() ??
          serverData['error']?.toString();
    }
    if (serverData is String && serverData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(serverData);
        if (decoded is Map<String, dynamic>) {
          return decoded['message']?.toString() ??
              decoded['msg']?.toString() ??
              decoded['error']?.toString();
        }
      } catch (_) {
        return serverData.trim();
      }
    }
    return null;
  }

  String _messageForStatusCode(int? statusCode) {
    if (statusCode == 404) return 'Endpoint not found';
    if (statusCode != null && statusCode >= 500) {
      return 'Server is temporarily unavailable';
    }
    if (statusCode != null && statusCode >= 400) return 'Request failed';
    return 'Network request failed';
  }
}

/// 对外暴露的 Lucent 网络入口实例。
final lucentClient = LucentApiClient.instance;

/// 暴露用于测试的 envelope 解析入口。
///
/// 将 `_request` 中的核心解析逻辑提取为可测试的静态方法。
@visibleForTesting
LucentApiResult<T> parseLucentResponse<T>({
  required Map<String, dynamic> rawData,
  required T Function(dynamic json) decoder,
}) {
  final code = LucentApiClient._parseCode(rawData['code']);
  final message = (rawData['message'] ?? '').toString();

  if (code != GlobalConstants.LUCENT_SUCCESS_CODE) {
    throw ApiException(
      message.isNotEmpty ? message : 'Request failed',
      code: code.toString(),
    );
  }

  return LucentApiResult<T>(
    code: code,
    message: message,
    data: decoder(rawData['data']),
    meta: rawData['meta'] != null
        ? LucentResponseMeta.fromJson(rawData['meta'] as Map<String, dynamic>)
        : null,
  );
}

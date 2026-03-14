// ignore_for_file: file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/loading_utils.dart';

// DioRequest：全站唯一网络入口（页面不要直接使用 Dio）。
//
// 设计目标：
// - 统一 baseUrl/超时/请求头
// - 统一 Loading（通过 options.extra 传 showLoading/loadingText）
// - 统一错误：后端 code!=SUCCESS_CODE 或 DioException 都抛 ApiException
// - 强类型解码：通过 decoder 把 result 转为业务对象，避免页面拿 dynamic/Map
//
// 约定的后端返回结构（必须统一，否则前端无法通用解析）：
//   { "code": "1", "msg": "...", "result": ... }
//
// 更多架构说明见：lib/project_guide.dart
class ApiResult<T> {
  final String code;
  final String msg;
  final T result;

  const ApiResult({
    required this.code,
    required this.msg,
    required this.result,
  });
}

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class DioRequest {
  DioRequest._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: GlobalConstants.BASE_URL,
        connectTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        receiveTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        sendTimeout: const Duration(seconds: GlobalConstants.TIME_OUT),
        responseType: ResponseType.json,
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (options.extra[_showLoadingKey] == true) {
            LoadingUtils.show(
              text: options.extra[_loadingTextKey]?.toString() ?? '加载中...',
            );
          }
          debugPrint('[DIO][REQ] ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (response.requestOptions.extra[_showLoadingKey] == true) {
            LoadingUtils.hide();
          }
          debugPrint(
            '[DIO][RES] ${response.statusCode} ${response.requestOptions.uri}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          if (error.requestOptions.extra[_showLoadingKey] == true) {
            LoadingUtils.hide();
          }
          final uri = error.requestOptions.uri;
          final statusCode = error.response?.statusCode;
          debugPrint('[DIO][ERR] $uri status=$statusCode msg=${error.message}');
          handler.reject(error);
        },
      ),
    );
  }

  static const String _showLoadingKey = 'showLoading';
  static const String _loadingTextKey = 'loadingText';

  static final DioRequest instance = DioRequest._internal();
  late final Dio _dio;

  Future<ApiResult<T>> get<T>(
    String path, {
    required T Function(dynamic json) decoder,
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    String loadingText = '加载中...',
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      'GET',
      path,
      decoder: decoder,
      queryParameters: queryParameters,
      showLoading: showLoading,
      loadingText: loadingText,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    required T Function(dynamic json) decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    String loadingText = '加载中...',
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request<T>(
      'POST',
      path,
      decoder: decoder,
      data: data,
      queryParameters: queryParameters,
      showLoading: showLoading,
      loadingText: loadingText,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<ApiResult<T>> _request<T>(
    String method,
    String path, {
    required T Function(dynamic json) decoder,
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    String loadingText = '加载中...',
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final requestOptions = (options ?? Options()).copyWith(method: method);
      requestOptions.extra = <String, dynamic>{
        ...?requestOptions.extra,
        _showLoadingKey: showLoading,
        _loadingTextKey: loadingText,
      };

      // 统一请求入口：这里是唯一发起 HTTP 的地方
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      // response.data 可能是 Map，也可能是 String(JSON)，这里统一转 Map<String, dynamic>
      final rawData = _coerceToMap(response.data);
      final code = (rawData['code'] ?? '').toString();
      final msg = (rawData['msg'] ?? '').toString();

      if (kDebugMode) {
        debugPrint(
          '[DIO][BIZ] code=$code msg=${msg.isEmpty ? '<empty>' : msg} uri=${response.requestOptions.uri}',
        );
      }

      if (code != GlobalConstants.SUCCESS_CODE) {
        // 业务失败：统一抛出 ApiException，页面只需要 try/catch 并提示 msg
        throw ApiException(msg.isEmpty ? '请求失败' : msg);
      }

      return ApiResult<T>(
        code: code,
        msg: msg,
        result: decoder(rawData['result']),
      );
    } on DioException catch (e) {
      // 网络失败/超时/非 2xx：统一包装成 ApiException
      throw ApiException(_parseDioError(e));
    }
  }

  Map<String, dynamic> _coerceToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String) {
      // 后端或网关可能返回 string，这里尝试 jsonDecode
      return _coerceToMap(jsonDecode(data));
    }
    throw Exception('响应格式异常：${data.runtimeType}');
  }

  String _parseDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverData = error.response?.data;

    final serverMessage = _extractServerMessage(serverData);
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }

    if (statusCode == 404) {
      return '接口不存在(404)，请检查请求路径和后端部署';
    }

    return '网络请求失败${statusCode == null ? '' : '($statusCode)'}：${error.message}';
  }

  String? _extractServerMessage(dynamic serverData) {
    if (serverData is Map<String, dynamic>) {
      return serverData['msg']?.toString() ?? serverData['error']?.toString();
    }

    if (serverData is Map) {
      return serverData['msg']?.toString() ?? serverData['error']?.toString();
    }

    if (serverData is String && serverData.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(serverData);
        if (decoded is Map<String, dynamic>) {
          return decoded['msg']?.toString() ?? decoded['error']?.toString();
        }
      } catch (_) {
        if (serverData.contains('Function Not Found')) {
          return '接口不存在，请检查云函数名称或部署状态';
        }
        return serverData.trim();
      }
    }

    return null;
  }
}

final dioRequest = DioRequest.instance;

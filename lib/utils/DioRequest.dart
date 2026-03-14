// ignore_for_file: file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/loading_utils.dart';

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
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
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

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    String loadingText = '加载中...',
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
      showLoading: showLoading,
      loadingText: loadingText,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    bool showLoading = false,
    String loadingText = '加载中...',
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _request(
      'POST',
      path,
      data: data,
      queryParameters: queryParameters,
      showLoading: showLoading,
      loadingText: loadingText,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
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

      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      final map = _coerceToMap(response.data);
      _throwIfApiError(map);
      return map;
    } on DioException catch (e) {
      throw ApiException(_parseDioError(e));
    }
  }

  Map<String, dynamic> _coerceToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }
    throw Exception('响应格式异常：${data.runtimeType}');
  }

  void _throwIfApiError(Map<String, dynamic> map) {
    if (map['error'] != null) {
      throw ApiException(map['error'].toString());
    }
    final ok = map['ok'];
    if (ok is bool && ok == false) {
      throw ApiException(map['msg']?.toString() ?? '请求失败');
    }
  }

  String _parseDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final serverData = error.response?.data;

    if (serverData is Map<String, dynamic>) {
      final msg =
          serverData['msg']?.toString() ?? serverData['error']?.toString();
      if (msg != null && msg.trim().isNotEmpty) {
        return msg;
      }
    }

    if (serverData is String && serverData.trim().isNotEmpty) {
      if (serverData.contains('Function Not Found')) {
        return '接口不存在，请检查云函数名称或部署状态';
      }
      return serverData.trim();
    }

    if (statusCode == 404) {
      return '接口不存在(404)，请检查请求路径和后端部署';
    }

    return '网络请求失败${statusCode == null ? '' : '($statusCode)'}：${error.message}';
  }
}

final dioRequest = DioRequest.instance;

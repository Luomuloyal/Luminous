// ignore_for_file: file_names

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/loading_utils.dart';

/// 通用接口返回包装。
///
/// 后端约定所有接口都返回 `{ code, msg, result }`，因此前端统一映射为这个结构。
class ApiResult<T> {
  /// 业务状态码。
  final String code;

  /// 后端返回的人类可读提示信息。
  final String msg;

  /// 经过 decoder 解析后的业务结果对象。
  final T result;

  /// 创建一个通用接口返回对象。
  const ApiResult({
    required this.code,
    required this.msg,
    required this.result,
  });
}

/// 统一的接口异常类型。
///
/// 页面层只需要 catch 这一种异常，然后把消息展示给用户即可。
class ApiException implements Exception {
  /// 具体错误消息。
  final String message;

  /// 创建一个接口异常对象。
  const ApiException(this.message);

  /// 返回可读的错误字符串。
  @override
  String toString() => message;
}

/// 项目统一网络入口。
///
/// 页面和 API 层不会直接使用 Dio，而是通过这个类统一处理：
/// - baseUrl/超时/请求头等基础配置；
/// - Loading 展示与隐藏；
/// - 错误包装成 `ApiException`；
/// - 统一解析 `{code,msg,result}` 并用 decoder 转为强类型对象。
class DioRequest {
  /// 私有构造函数。
  ///
  /// 在构造时完成 Dio 实例与拦截器初始化。
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

          /// 发生网络异常时的请求地址。
          final uri = error.requestOptions.uri;

          /// 当前异常对应的 HTTP 状态码。
          final statusCode = error.response?.statusCode;

          debugPrint('[DIO][ERR] $uri status=$statusCode msg=${error.message}');
          handler.reject(error);
        },
      ),
    );
  }

  /// request.extra 中用于控制是否展示全局 Loading 的 key。
  static const String _showLoadingKey = 'showLoading';

  /// request.extra 中用于传递 Loading 文案的 key。
  static const String _loadingTextKey = 'loadingText';

  /// DioRequest 的全局单例实例。
  static final DioRequest instance = DioRequest._internal();

  /// 底层 Dio 实例。
  late final Dio _dio;

  /// 发起 GET 请求。
  ///
  /// 所有 GET 请求最终都会进入 `_request` 统一处理。
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

  /// 发起 POST 请求。
  ///
  /// 所有 POST 请求最终都会进入 `_request` 统一处理。
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

  /// 发起真正的 HTTP 请求并做统一响应处理。
  ///
  /// 这里是整个应用唯一执行网络请求的地方。
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
      /// 本次请求最终使用的 Dio 配置对象。
      final requestOptions = (options ?? Options()).copyWith(method: method);
      requestOptions.extra = <String, dynamic>{
        ...?requestOptions.extra,
        _showLoadingKey: showLoading,
        _loadingTextKey: loadingText,
      };

      /// 底层返回的原始 HTTP 响应对象。
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: cancelToken,
      );

      /// 统一整理后的 Map 结构响应数据。
      final rawData = _coerceToMap(response.data);

      /// 业务状态码。
      final code = (rawData['code'] ?? '').toString();

      /// 业务提示消息。
      final msg = (rawData['msg'] ?? '').toString();

      if (kDebugMode) {
        debugPrint(
          '[DIO][BIZ] code=$code msg=${msg.isEmpty ? '<empty>' : msg} uri=${response.requestOptions.uri}',
        );
      }

      if (code != GlobalConstants.SUCCESS_CODE) {
        throw ApiException(msg.isEmpty ? '请求失败' : msg);
      }

      return ApiResult<T>(
        code: code,
        msg: msg,
        result: decoder(rawData['result']),
      );
    } on DioException catch (e) {
      throw ApiException(_parseDioError(e));
    }
  }

  /// 把后端返回的动态数据统一整理成 `Map<String, dynamic>`。
  ///
  /// 兼容：
  /// - `Map<String, dynamic>`；
  /// - 普通 `Map`；
  /// - JSON 字符串。
  Map<String, dynamic> _coerceToMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String) {
      return _coerceToMap(jsonDecode(data));
    }
    throw Exception('响应格式异常：${data.runtimeType}');
  }

  /// 把 Dio 异常转换成适合展示给用户的消息。
  String _parseDioError(DioException error) {
    /// HTTP 状态码。
    final statusCode = error.response?.statusCode;

    /// 服务端返回的原始错误体。
    final serverData = error.response?.data;

    /// 从服务端错误体中提取出的消息。
    final serverMessage = _extractServerMessage(serverData);
    if (serverMessage != null && serverMessage.trim().isNotEmpty) {
      return serverMessage;
    }

    if (statusCode == 404) {
      return '接口不存在(404)，请检查请求路径和后端部署';
    }

    return '网络请求失败${statusCode == null ? '' : '($statusCode)'}：${error.message}';
  }

  /// 尝试从服务端错误响应中提取可读错误消息。
  ///
  /// 兼容 Map、字符串 JSON、纯文本错误等多种情况。
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

/// 对外暴露的全局网络入口实例。
final dioRequest = DioRequest.instance;

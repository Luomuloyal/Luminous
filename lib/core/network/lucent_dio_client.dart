import 'package:dio/dio.dart';
import 'package:lucent_openapi/lucent_openapi.dart';

/// Luminous 对 Lucent OpenAPI 客户端的统一封装入口。
///
/// 约定：
/// - 生成代码放在 `packages/lucent_openapi`
/// - 业务层不要直接 new 生成器里的 `LucentOpenapi`
/// - 统一通过这里注入 baseUrl、token 和通用 Dio 行为
class LucentDioClient {
  LucentDioClient({
    required String baseUrl,
    String? accessToken,
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
         interceptors: <Interceptor>[
           ...interceptors,
           ..._defaultInterceptors,
         ],
       ) {
    setAccessToken(accessToken);
  }

  final LucentOpenapi _openapi;

  static final List<Interceptor> _defaultInterceptors = <Interceptor>[
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers.putIfAbsent('Accept', () => 'application/json');
        handler.next(options);
      },
    ),
  ];

  Dio get dio => _openapi.dio;

  AppApi get appApi => _openapi.getAppApi();

  AuthApi get authApi => _openapi.getAuthApi();

  void setAccessToken(String? token) {
    _openapi.removeBearerAuth('access-token');
    final value = token?.trim() ?? '';
    if (value.isNotEmpty) {
      _openapi.setBearerAuth('access-token', value);
    }
  }
}

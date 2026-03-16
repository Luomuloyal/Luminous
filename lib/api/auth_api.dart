import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 认证相关接口封装。
///
/// 页面不会直接拼接认证接口路径或业务字段，而是统一通过这个类调用。
class AuthApi {
  /// 私有构造函数，当前类只作为静态方法容器使用。
  AuthApi._();

  /// 请求 SVG 验证码。
  ///
  /// 用于“SVG 测试登录/注册”流程，后端约定 `type = 1` 表示 SVG 验证码。
  static Future<ApiResult<SvgCodeResult>> fetchSvgCode() {
    return dioRequest.post<SvgCodeResult>(
      HttpConstants.SEND_CODE,
      data: const {'type': 1},
      decoder: (json) => SvgCodeResult.fromJson(_asMap(json)),
    );
  }

  /// 向指定邮箱发送邮箱验证码。
  ///
  /// 后端约定 `type = 2` 表示邮箱验证码发送流程。
  static Future<ApiResult<EmailCodeResult>> sendEmailCode(String email) {
    return dioRequest.post<EmailCodeResult>(
      HttpConstants.SEND_CODE,
      data: {'type': 2, 'value': email},
      decoder: (json) => EmailCodeResult.fromJson(_asMap(json)),
    );
  }

  /// 使用邮箱验证码完成注册。
  ///
  /// 这里会统一把注册接口所需的 `type/codeType/username/email` 等协议字段封装好。
  static Future<ApiResult<RegisterResult>> registerWithEmail({
    required String email,
    required String password,
    required String code,
  }) {
    return dioRequest.post<RegisterResult>(
      HttpConstants.REGISTER_USER,
      data: {
        'type': 2,
        'username': email,
        'email': email,
        'password': password,
        'code': code,
        'codeType': 2,
      },
      showLoading: true,
      loadingText: '注册中...',
      decoder: (json) => RegisterResult.fromJson(_asMap(json)),
    );
  }

  /// 使用 SVG 验证码完成注册。
  ///
  /// 适用于测试账号联调场景，必须同时传入验证码和对应的 `uuid`。
  static Future<ApiResult<RegisterResult>> registerWithSvg({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) {
    return dioRequest.post<RegisterResult>(
      HttpConstants.REGISTER_USER,
      data: {
        'type': 1,
        'username': username,
        'password': password,
        'code': code,
        'codeType': 1,
        'uuid': uuid,
      },
      showLoading: true,
      loadingText: '注册中...',
      decoder: (json) => RegisterResult.fromJson(_asMap(json)),
    );
  }

  /// 使用邮箱密码登录。
  ///
  /// 接口返回值会被解析为安全用户对象 `UserSafe`，供全局用户态使用。
  static Future<ApiResult<UserSafe>> loginWithEmail({
    required String email,
    required String password,
  }) {
    return dioRequest.post<UserSafe>(
      HttpConstants.LOGIN_USER,
      data: {
        'type': 2,
        'username': email,
        'email': email,
        'password': password,
      },
      showLoading: true,
      loadingText: '登录中...',
      decoder: (json) => UserSafe.fromJson(_asMap(json)),
    );
  }

  /// 使用 SVG 验证码登录。
  ///
  /// 主要用于验证码联调场景，与邮箱登录的区别是必须附带 `code` 和 `uuid`。
  static Future<ApiResult<UserSafe>> loginWithSvg({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) {
    return dioRequest.post<UserSafe>(
      HttpConstants.LOGIN_USER,
      data: {
        'type': 1,
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      },
      showLoading: true,
      loadingText: '登录中...',
      decoder: (json) => UserSafe.fromJson(_asMap(json)),
    );
  }

  /// 把不稳定的动态 JSON 数据安全转换为 `Map<String, dynamic>`。
  ///
  /// 统一在 API 层做这一步，避免页面和模型层直接处理 `dynamic`。
  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

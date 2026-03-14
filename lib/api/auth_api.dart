import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/DioRequest.dart';
import 'package:luminous/viewmodels/auth.dart';

class AuthApi {
  AuthApi._();

  static Future<ApiResult<SvgCodeResult>> fetchSvgCode() {
    return dioRequest.post<SvgCodeResult>(
      HttpConstants.SEND_CODE,
      data: const {'type': 1},
      decoder: (json) => SvgCodeResult.fromJson(_asMap(json)),
    );
  }

  static Future<ApiResult<EmailCodeResult>> sendEmailCode(String email) {
    return dioRequest.post<EmailCodeResult>(
      HttpConstants.SEND_CODE,
      data: {'type': 2, 'value': email},
      decoder: (json) => EmailCodeResult.fromJson(_asMap(json)),
    );
  }

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

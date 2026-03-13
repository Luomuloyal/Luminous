import 'package:luminous/utils/DioRequest.dart';

class AuthApi {
  AuthApi._();

  static const String _sendCodePath = '/send-code';
  static const String _registerPath = '/register-user';
  static const String _loginPath = '/login-user';

  static Future<Map<String, dynamic>> fetchSvgCode() {
    return dioRequest.post(_sendCodePath, data: {'type': 1});
  }

  static Future<Map<String, dynamic>> sendEmailCode(String email) {
    return dioRequest.post(_sendCodePath, data: {'type': 2, 'value': email});
  }

  static Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
    required String code,
  }) {
    return dioRequest.post(
      _registerPath,
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
    );
  }

  static Future<Map<String, dynamic>> registerWithSvg({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) {
    return dioRequest.post(
      _registerPath,
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
    );
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String code,
    required String uuid,
  }) {
    return dioRequest.post(
      _loginPath,
      data: {
        'username': username,
        'password': password,
        'code': code,
        'uuid': uuid,
      },
      showLoading: true,
      loadingText: '登录中...',
    );
  }
}

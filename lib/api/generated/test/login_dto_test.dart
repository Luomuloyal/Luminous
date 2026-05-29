import 'package:test/test.dart';
import 'package:luminous_api/luminous_api.dart';

// tests for LoginDto
void main() {
  final instance = LoginDtoBuilder();
  // TODO add properties to the builder and call build()

  group(LoginDto, () {
    // 邮箱地址
    // String email
    test('to test the property `email`', () async {
      // TODO
    });

    // 密码（与验证码二选一）
    // String password
    test('to test the property `password`', () async {
      // TODO
    });

    // 邮箱验证码（与密码二选一）
    // String code
    test('to test the property `code`', () async {
      // TODO
    });

  });
}

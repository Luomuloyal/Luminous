import 'package:test/test.dart';
import 'package:luminous_api/luminous_api.dart';


/// tests for AuthApi
void main() {
  final instance = LuminousApi().getAuthApi();

  group(AuthApi, () {
    // 修改邮箱
    //
    //Future<ChangeEmailResponseDto> authControllerChangeEmailV1(ChangeEmailDto changeEmailDto) async
    test('test authControllerChangeEmailV1', () async {
      // TODO
    });

    // 修改密码
    //
    //Future<SuccessResponseDto> authControllerChangePasswordV1(ChangePasswordDto changePasswordDto) async
    test('test authControllerChangePasswordV1', () async {
      // TODO
    });

    // 注销账户
    //
    //Future<SuccessResponseDto> authControllerDeleteAccountV1(DeleteAccountDto deleteAccountDto) async
    test('test authControllerDeleteAccountV1', () async {
      // TODO
    });

    // 忘记密码
    //
    //Future<ForgotPasswordResponseDto> authControllerForgotPasswordV1(ForgotPasswordDto forgotPasswordDto) async
    test('test authControllerForgotPasswordV1', () async {
      // TODO
    });

    // 获取当前用户信息
    //
    //Future<MeResponseDto> authControllerGetMeV1() async
    test('test authControllerGetMeV1', () async {
      // TODO
    });

    // 用户登录
    //
    //Future<LoginResponseDto> authControllerLoginV1(LoginDto loginDto) async
    test('test authControllerLoginV1', () async {
      // TODO
    });

    // 用户登出
    //
    //Future<SuccessResponseDto> authControllerLogoutV1(LogoutDto logoutDto) async
    test('test authControllerLogoutV1', () async {
      // TODO
    });

    // 刷新令牌
    //
    //Future<RefreshResponseDto> authControllerRefreshV1(RefreshDto refreshDto) async
    test('test authControllerRefreshV1', () async {
      // TODO
    });

    // 用户注册
    //
    //Future<RegisterResponseDto> authControllerRegisterV1(RegisterDto registerDto) async
    test('test authControllerRegisterV1', () async {
      // TODO
    });

    // 重置密码
    //
    //Future<SuccessResponseDto> authControllerResetPasswordV1(ResetPasswordDto resetPasswordDto) async
    test('test authControllerResetPasswordV1', () async {
      // TODO
    });

    // 发送邮箱验证码
    //
    //Future<SendVerificationCodeResponseDto> authControllerSendVerificationCodeV1(SendVerificationCodeDto sendVerificationCodeDto) async
    test('test authControllerSendVerificationCodeV1', () async {
      // TODO
    });

    // 更新当前用户信息
    //
    //Future<MeResponseDto> authControllerUpdateMeV1(UpdateMeDto updateMeDto) async
    test('test authControllerUpdateMeV1', () async {
      // TODO
    });

    // 验证邮箱
    //
    //Future<VerifyEmailResponseDto> authControllerVerifyEmailV1(VerifyEmailDto verifyEmailDto) async
    test('test authControllerVerifyEmailV1', () async {
      // TODO
    });

  });
}

import 'package:luminous/core/network/lucent_api.dart';
import 'package:luminous/features/auth/data/mappers/auth_mapper.dart';
import 'package:luminous/features/auth/domain/entities/auth_session.dart';

enum AuthVerificationScene {
  register,
  login,
  resetPassword,
  changeEmail;

  SendVerificationCodeDtoSceneEnum toDtoScene() {
    return switch (this) {
      AuthVerificationScene.register =>
        SendVerificationCodeDtoSceneEnum.register,
      AuthVerificationScene.login => SendVerificationCodeDtoSceneEnum.login,
      AuthVerificationScene.resetPassword =>
        SendVerificationCodeDtoSceneEnum.resetPassword,
      AuthVerificationScene.changeEmail =>
        SendVerificationCodeDtoSceneEnum.changeEmail,
    };
  }
}

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._client);

  final LucentDioClient _client;

  Future<AuthSession> login({
    required String email,
    String? password,
    String? code,
  }) async {
    final response = await _client.authApi.authControllerLoginV1(
      loginDto: LoginDto(
        email: email.trim(),
        password: password?.trim().isEmpty ?? true ? null : password!.trim(),
        code: code?.trim().isEmpty ?? true ? null : code!.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Login response is empty.');
    }
    final session = AuthMapper.toSessionFromLogin(body);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<AuthSession> register({
    required String email,
    required String password,
    required String code,
    String? nickname,
  }) async {
    final response = await _client.authApi.authControllerRegisterV1(
      registerDto: RegisterDto(
        email: email.trim(),
        password: password.trim(),
        code: code.trim(),
        nickname: nickname?.trim().isEmpty ?? true ? null : nickname!.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Register response is empty.');
    }
    final session = AuthMapper.toSessionFromRegister(body);
    await _client.writeSession(
      LucentSessionTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
    return session;
  }

  Future<void> logout() async {
    final refreshToken = await _client.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _client.clearSession();
      return;
    }

    await _client.authApi.authControllerLogoutV1(
      logoutDto: LogoutDto(refreshToken: refreshToken),
    );
    await _client.clearSession();
  }

  Future<AuthUser> fetchMe() async {
    final response = await _client.authApi.authControllerGetMeV1();
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(message: 'Me response is empty.');
    }
    final user = body.data;
    return AuthUser(
      id: user.id,
      email: user.email,
      nickname: user.nickname?.toString(),
      avatar: user.avatar?.toString(),
      emailVerified: user.emailVerified,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt),
    );
  }

  Future<CooldownMessageDto> sendVerificationCode({
    required String email,
    required AuthVerificationScene scene,
  }) async {
    final response = await _client.authApi.authControllerSendVerificationCodeV1(
      sendVerificationCodeDto: SendVerificationCodeDto(
        email: email.trim(),
        scene: scene.toDtoScene(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Send verification code response is empty.',
      );
    }
    return body.data;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _client.authApi.authControllerResetPasswordV1(
      resetPasswordDto: ResetPasswordDto(
        email: email.trim(),
        code: code.trim(),
        password: password.trim(),
      ),
    );
  }

  Future<CooldownMessageDto> forgotPassword({required String email}) async {
    final response = await _client.authApi.authControllerForgotPasswordV1(
      forgotPasswordDto: ForgotPasswordDto(email: email.trim()),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Forgot password response is empty.',
      );
    }
    return body.data;
  }

  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _client.authApi.authControllerVerifyEmailV1(
      verifyEmailDto: VerifyEmailDto(email: email.trim(), code: code.trim()),
    );
  }

  Future<AuthUser> updateMe({String? nickname, String? avatar}) async {
    final response = await _client.authApi.authControllerUpdateMeV1(
      updateMeDto: UpdateMeDto(
        nickname: nickname?.trim().isEmpty ?? true ? null : nickname!.trim(),
        avatar: avatar?.trim().isEmpty ?? true ? null : avatar!.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Update profile response is empty.',
      );
    }
    final user = body.data;
    return AuthUser(
      id: user.id,
      email: user.email,
      nickname: user.nickname?.toString(),
      avatar: user.avatar?.toString(),
      emailVerified: user.emailVerified,
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.parse(user.updatedAt),
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _client.authApi.authControllerChangePasswordV1(
      changePasswordDto: ChangePasswordDto(
        oldPassword: oldPassword.trim(),
        newPassword: newPassword.trim(),
      ),
    );
    await _client.clearSession();
  }

  Future<AuthUser> changeEmail({
    required String newEmail,
    required String code,
    required AuthUser currentUser,
  }) async {
    final response = await _client.authApi.authControllerChangeEmailV1(
      changeEmailDto: ChangeEmailDto(
        newEmail: newEmail.trim(),
        code: code.trim(),
      ),
    );
    final body = response.data;
    if (body == null) {
      throw const LucentApiException(
        message: 'Change email response is empty.',
      );
    }
    return currentUser.copyWith(
      email: body.data.email,
      emailVerified: body.data.emailVerified,
    );
  }

  Future<void> deleteAccount({required String password}) async {
    await _client.authApi.authControllerDeleteAccountV1(
      deleteAccountDto: DeleteAccountDto(password: password.trim()),
    );
    await _client.clearSession();
  }
}

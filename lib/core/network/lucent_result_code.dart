abstract final class LucentResultCode {
  static const int success = 0;

  static const int badRequest = 400001;
  static const int validationFailed = 400002;
  static const int verificationCodeInvalid = 400100;
  static const int verificationCodeCooldown = 400101;

  static const int unauthorized = 401001;
  static const int tokenExpired = 401002;
  static const int refreshTokenInvalid = 401003;
  static const int loginRateLimited = 401004;
  static const int wrongPassword = 401005;

  static const int forbidden = 403001;
  static const int notFound = 404001;
  static const int conflict = 409001;

  static const int internalError = 500001;
  static const int databaseError = 500002;
  static const int externalServiceError = 500003;
}

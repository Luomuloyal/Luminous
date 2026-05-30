class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.avatar,
    required this.emailVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String? nickname;
  final String? avatar;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresInSeconds,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;
  final int expiresInSeconds;
}

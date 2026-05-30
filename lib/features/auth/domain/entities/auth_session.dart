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

  AuthUser copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatar,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
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

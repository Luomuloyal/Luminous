/// 认证模块相关的数据模型集合。
///
/// 该文件主要承载：
/// - 验证码接口返回的数据结构；
/// - 注册接口返回的数据结构；
/// - 登录后用于前端展示与本地持久化的安全用户对象（不包含敏感 token）。
enum AuthIdentifierType { phone, email }

enum AuthCodeScene { register, login }

enum AuthLoginMode { password, code }

extension AuthIdentifierTypeValue on AuthIdentifierType {
  String get backendValue =>
      this == AuthIdentifierType.phone ? 'phone' : 'email';

  String get label => this == AuthIdentifierType.phone ? '手机号' : '邮箱';

  String get alternateActionText =>
      this == AuthIdentifierType.phone ? '切换邮箱登录' : '切换手机号登录';

  String get registerLabel =>
      this == AuthIdentifierType.phone ? '手机号注册' : '邮箱注册';
}

extension AuthCodeSceneValue on AuthCodeScene {
  String get backendValue =>
      this == AuthCodeScene.register ? 'register' : 'login';
}

extension AuthLoginModeValue on AuthLoginMode {
  String get label => this == AuthLoginMode.password ? '密码登录' : '验证码登录';

  String get backendValue =>
      this == AuthLoginMode.password ? 'password' : 'code';
}

class CodeTicketResult {
  /// 验证码发送记录 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// 创建一个验证码发送结果对象。
  const CodeTicketResult({required this.id});

  /// 从后端 JSON 反序列化为 `CodeTicketResult`。
  factory CodeTicketResult.fromJson(Map<String, dynamic> json) {
    return CodeTicketResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }
}

class RegisterResult {
  /// 注册结果 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// accessToken，注册即颁发登录态
  final String accessToken;

  /// refreshToken，用于续签
  final String refreshToken;

  /// 创建一个注册结果对象。
  const RegisterResult({
    required this.id,
    this.accessToken = '',
    this.refreshToken = '',
  });

  /// 从后端 JSON 反序列化为 `RegisterResult`。
  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      accessToken: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
    );
  }
}

/// 登录接口返回对象。
class LoginResult {
  /// 登录后的用户信息。
  final UserSafe user;

  /// 登录后返回的访问令牌 (accessToken)。
  final String token;

  /// 用于后续无感续签的 token。
  final String refreshToken;

  /// 创建一个登录结果对象。
  const LoginResult({
    required this.user,
    required this.token,
    required this.refreshToken,
  });

  /// 从后端 JSON 反序列化为 `LoginResult`。
  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final userJson = rawUser is Map<String, dynamic>
        ? rawUser
        : rawUser is Map
        ? rawUser.map((key, value) => MapEntry(key.toString(), value))
        : <String, dynamic>{};

    return LoginResult(
      user: UserSafe.fromJson(userJson),
      token: (json['accessToken'] ?? '').toString(),
      refreshToken: (json['refreshToken'] ?? '').toString(),
    );
  }
}

/// 登录后前端使用的“安全用户对象”。
///
/// 该对象用于：
/// - 页面展示（Mine 页头像/昵称等）；
/// - 本地持久化（SharedPreferences）；
///
/// 注意：这里不包含 token 等敏感信息，后续如果接 token 鉴权，建议放到单独模型里管理。
class UserSafe {
  /// 用户 id（后端可能返回 `_id` 或 `id`）。
  final String id;

  /// 用户名（登录/注册的 username 字段）。
  final String username;

  /// 邮箱。
  final String email;

  /// 手机号（可选字段）。
  final String phone;

  /// 显示名称（昵称/姓名等，可选字段）。
  final String name;

  /// 用户类型（后端定义，通常用于区分测试用户/普通用户等）。
  final int type;

  /// 创建一个 `UserSafe` 对象。
  const UserSafe({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.name,
    required this.type,
  });

  /// 从后端 JSON 反序列化为 `UserSafe`。
  ///
  /// 兼容字段：`_id/id`。
  factory UserSafe.fromJson(Map<String, dynamic> json) {
    return UserSafe(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      type: int.tryParse((json['type'] ?? '').toString()) ?? 0,
    );
  }

  /// 序列化为 JSON Map，用于本地持久化。
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'name': name,
      'type': type,
    };
  }

  /// 当前用户对象是否包含有效数据。
  ///
  /// 目前用 `id` 是否为空作为判断依据。
  bool get hasData => id.isNotEmpty;

  /// 页面上用于展示的主标题（优先级：name > username > email > phone）。
  String get displayTitle {
    if (name.isNotEmpty) {
      return name;
    }
    if (username.isNotEmpty) {
      return username;
    }
    if (email.isNotEmpty) {
      return email;
    }
    if (phone.isNotEmpty) {
      return phone;
    }
    return '未登录';
  }

  /// 页面上用于展示的副标题（把 username/email/phone 以 ` · ` 连接）。
  ///
  /// 如果没有任何信息，则回退为引导语。
  String get displaySubtitle {
    final title = displayTitle;
    final values = <String>{
      if (username.isNotEmpty && username != title) username,
      if (email.isNotEmpty && email != title) email,
      if (phone.isNotEmpty && phone != title) phone,
    };
    if (values.isEmpty) {
      return hasData ? '账号信息已同步' : '登录后可同步你的账号信息';
    }
    return values.join(' · ');
  }
}

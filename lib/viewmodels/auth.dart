class SvgCodeResult {
  final String id;
  final String svg;

  const SvgCodeResult({required this.id, required this.svg});

  factory SvgCodeResult.fromJson(Map<String, dynamic> json) {
    return SvgCodeResult(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      svg: (json['svg'] ?? '').toString(),
    );
  }
}

class EmailCodeResult {
  final String id;

  const EmailCodeResult({required this.id});

  factory EmailCodeResult.fromJson(Map<String, dynamic> json) {
    return EmailCodeResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }
}

class RegisterResult {
  final String id;

  const RegisterResult({required this.id});

  factory RegisterResult.fromJson(Map<String, dynamic> json) {
    return RegisterResult(id: (json['id'] ?? json['_id'] ?? '').toString());
  }
}

class UserSafe {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String name;
  final int type;

  const UserSafe({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.name,
    required this.type,
  });

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

  bool get hasData => id.isNotEmpty;

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

  String get displaySubtitle {
    final values = <String>{
      if (username.isNotEmpty) username,
      if (email.isNotEmpty) email,
      if (phone.isNotEmpty) phone,
    };
    if (values.isEmpty) {
      return '登录后可同步你的账号信息';
    }
    return values.join(' · ');
  }
}

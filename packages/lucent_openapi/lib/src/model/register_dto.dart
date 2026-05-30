//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'register_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDto {
  /// Returns a new [RegisterDto] instance.
  RegisterDto({
    required this.email,

    required this.password,

    required this.code,

    this.nickname,
  });

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'password', required: true, includeIfNull: false)
  final String password;

  /// 邮箱验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  /// 昵称
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterDto &&
          other.email == email &&
          other.password == password &&
          other.code == code &&
          other.nickname == nickname;

  @override
  int get hashCode =>
      email.hashCode + password.hashCode + code.hashCode + nickname.hashCode;

  factory RegisterDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

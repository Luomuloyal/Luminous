//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'send_verification_code_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SendVerificationCodeDto {
  /// Returns a new [SendVerificationCodeDto] instance.
  SendVerificationCodeDto({required this.email, required this.scene});

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 验证码场景
  @JsonKey(
    name: r'scene',
    required: true,
    includeIfNull: false,
    unknownEnumValue: SendVerificationCodeDtoSceneEnum.unknownDefaultOpenApi,
  )
  final SendVerificationCodeDtoSceneEnum scene;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendVerificationCodeDto &&
          other.email == email &&
          other.scene == scene;

  @override
  int get hashCode => email.hashCode + scene.hashCode;

  factory SendVerificationCodeDto.fromJson(Map<String, dynamic> json) =>
      _$SendVerificationCodeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SendVerificationCodeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

/// 验证码场景
enum SendVerificationCodeDtoSceneEnum {
  /// 验证码场景
  @JsonValue(r'register')
  register(r'register'),

  /// 验证码场景
  @JsonValue(r'login')
  login(r'login'),

  /// 验证码场景
  @JsonValue(r'reset-password')
  resetPassword(r'reset-password'),

  /// 验证码场景
  @JsonValue(r'change-email')
  changeEmail(r'change-email'),

  /// 验证码场景
  @JsonValue(r'unknown_default_open_api')
  unknownDefaultOpenApi(r'unknown_default_open_api');

  const SendVerificationCodeDtoSceneEnum(this.value);

  final String value;

  @override
  String toString() => value;
}

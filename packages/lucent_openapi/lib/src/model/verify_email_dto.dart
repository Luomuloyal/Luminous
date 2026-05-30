//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailDto {
  /// Returns a new [VerifyEmailDto] instance.
  VerifyEmailDto({required this.email, required this.code});

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyEmailDto && other.email == email && other.code == code;

  @override
  int get hashCode => email.hashCode + code.hashCode;

  factory VerifyEmailDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

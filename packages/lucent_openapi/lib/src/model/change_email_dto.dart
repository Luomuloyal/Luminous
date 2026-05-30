//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'change_email_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeEmailDto {
  /// Returns a new [ChangeEmailDto] instance.
  ChangeEmailDto({required this.newEmail, required this.code});

  /// 新邮箱
  @JsonKey(name: r'newEmail', required: true, includeIfNull: false)
  final String newEmail;

  /// 验证码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final String code;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangeEmailDto &&
          other.newEmail == newEmail &&
          other.code == code;

  @override
  int get hashCode => newEmail.hashCode + code.hashCode;

  factory ChangeEmailDto.fromJson(Map<String, dynamic> json) =>
      _$ChangeEmailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeEmailDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

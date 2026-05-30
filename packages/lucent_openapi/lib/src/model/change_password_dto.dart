//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'change_password_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangePasswordDto {
  /// Returns a new [ChangePasswordDto] instance.
  ChangePasswordDto({required this.oldPassword, required this.newPassword});

  /// 当前密码
  @JsonKey(name: r'oldPassword', required: true, includeIfNull: false)
  final String oldPassword;

  /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(name: r'newPassword', required: true, includeIfNull: false)
  final String newPassword;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChangePasswordDto &&
          other.oldPassword == oldPassword &&
          other.newPassword == newPassword;

  @override
  int get hashCode => oldPassword.hashCode + newPassword.hashCode;

  factory ChangePasswordDto.fromJson(Map<String, dynamic> json) =>
      _$ChangePasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangePasswordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

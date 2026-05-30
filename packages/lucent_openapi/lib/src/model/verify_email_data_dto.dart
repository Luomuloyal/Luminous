//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailDataDto {
  /// Returns a new [VerifyEmailDataDto] instance.
  VerifyEmailDataDto({required this.emailVerified});

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyEmailDataDto && other.emailVerified == emailVerified;

  @override
  int get hashCode => emailVerified.hashCode;

  factory VerifyEmailDataDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

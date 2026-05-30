//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/verify_email_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'verify_email_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VerifyEmailResponseDto {
  /// Returns a new [VerifyEmailResponseDto] instance.
  VerifyEmailResponseDto({
    required this.code,

    required this.message,

    required this.data,
  });

  /// 结果码
  @JsonKey(name: r'code', required: true, includeIfNull: false)
  final num code;

  /// 提示消息
  @JsonKey(name: r'message', required: true, includeIfNull: false)
  final String message;

  @JsonKey(name: r'data', required: true, includeIfNull: false)
  final VerifyEmailDataDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyEmailResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory VerifyEmailResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/user_full_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'me_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MeResponseDto {
  /// Returns a new [MeResponseDto] instance.
  MeResponseDto({
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
  final UserFullDto data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode => code.hashCode + message.hashCode + data.hashCode;

  factory MeResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MeResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MeResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

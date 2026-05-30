//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'success_response_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SuccessResponseDto {
  /// Returns a new [SuccessResponseDto] instance.
  SuccessResponseDto({
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

  /// 数据
  @JsonKey(name: r'data', required: true, includeIfNull: true)
  final Object? data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SuccessResponseDto &&
          other.code == code &&
          other.message == message &&
          other.data == data;

  @override
  int get hashCode =>
      code.hashCode + message.hashCode + (data == null ? 0 : data.hashCode);

  factory SuccessResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SuccessResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SuccessResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

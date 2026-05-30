//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/tokens_dto.dart';
import 'package:lucent_openapi/src/model/user_brief_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_data_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterDataDto {
  /// Returns a new [RegisterDataDto] instance.
  RegisterDataDto({required this.user, required this.tokens});

  @JsonKey(name: r'user', required: true, includeIfNull: false)
  final UserBriefDto user;

  @JsonKey(name: r'tokens', required: true, includeIfNull: false)
  final TokensDto tokens;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterDataDto && other.user == user && other.tokens == tokens;

  @override
  int get hashCode => user.hashCode + tokens.hashCode;

  factory RegisterDataDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

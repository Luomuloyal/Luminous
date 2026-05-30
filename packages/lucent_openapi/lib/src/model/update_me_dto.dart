//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'update_me_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UpdateMeDto {
  /// Returns a new [UpdateMeDto] instance.
  UpdateMeDto({this.nickname, this.avatar});

  /// 昵称
  @JsonKey(name: r'nickname', required: false, includeIfNull: false)
  final String? nickname;

  /// 头像 URL
  @JsonKey(name: r'avatar', required: false, includeIfNull: false)
  final String? avatar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateMeDto &&
          other.nickname == nickname &&
          other.avatar == avatar;

  @override
  int get hashCode => nickname.hashCode + avatar.hashCode;

  factory UpdateMeDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateMeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateMeDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

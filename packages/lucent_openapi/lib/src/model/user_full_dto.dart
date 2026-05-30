//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'user_full_dto.g.dart';

@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserFullDto {
  /// Returns a new [UserFullDto] instance.
  UserFullDto({
    required this.id,

    required this.email,

    required this.nickname,

    required this.avatar,

    required this.emailVerified,

    required this.createdAt,

    required this.updatedAt,
  });

  /// 用户 ID
  @JsonKey(name: r'id', required: true, includeIfNull: false)
  final String id;

  /// 邮箱地址
  @JsonKey(name: r'email', required: true, includeIfNull: false)
  final String email;

  /// 昵称
  @JsonKey(name: r'nickname', required: true, includeIfNull: true)
  final Object? nickname;

  /// 头像 URL
  @JsonKey(name: r'avatar', required: true, includeIfNull: true)
  final Object? avatar;

  /// 邮箱是否已验证
  @JsonKey(name: r'emailVerified', required: true, includeIfNull: false)
  final bool emailVerified;

  /// 创建时间 (ISO 8601)
  @JsonKey(name: r'createdAt', required: true, includeIfNull: false)
  final String createdAt;

  /// 更新时间 (ISO 8601)
  @JsonKey(name: r'updatedAt', required: true, includeIfNull: false)
  final String updatedAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserFullDto &&
          other.id == id &&
          other.email == email &&
          other.nickname == nickname &&
          other.avatar == avatar &&
          other.emailVerified == emailVerified &&
          other.createdAt == createdAt &&
          other.updatedAt == updatedAt;

  @override
  int get hashCode =>
      id.hashCode +
      email.hashCode +
      (nickname == null ? 0 : nickname.hashCode) +
      (avatar == null ? 0 : avatar.hashCode) +
      emailVerified.hashCode +
      createdAt.hashCode +
      updatedAt.hashCode;

  factory UserFullDto.fromJson(Map<String, dynamic> json) =>
      _$UserFullDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserFullDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }
}

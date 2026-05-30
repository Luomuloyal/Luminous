//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'user_brief_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserBriefDto {
  /// Returns a new [UserBriefDto] instance.
  UserBriefDto({

    required  this.id,

    required  this.email,

    required  this.nickname,

    required  this.emailVerified,

    required  this.createdAt,
  });

      /// 用户 ID
  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



      /// 邮箱地址
  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



      /// 昵称
  @JsonKey(
    
    name: r'nickname',
    required: true,
    includeIfNull: true,
  )


  final Object? nickname;



      /// 邮箱是否已验证
  @JsonKey(
    
    name: r'emailVerified',
    required: true,
    includeIfNull: false,
  )


  final bool emailVerified;



      /// 创建时间 (ISO 8601)
  @JsonKey(
    
    name: r'createdAt',
    required: true,
    includeIfNull: false,
  )


  final String createdAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserBriefDto &&
      other.id == id &&
      other.email == email &&
      other.nickname == nickname &&
      other.emailVerified == emailVerified &&
      other.createdAt == createdAt;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        (nickname == null ? 0 : nickname.hashCode) +
        emailVerified.hashCode +
        createdAt.hashCode;

  factory UserBriefDto.fromJson(Map<String, dynamic> json) => _$UserBriefDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserBriefDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


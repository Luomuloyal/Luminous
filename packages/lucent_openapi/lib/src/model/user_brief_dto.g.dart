// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_brief_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserBriefDto _$UserBriefDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserBriefDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'email',
          'nickname',
          'emailVerified',
          'createdAt',
        ],
      );
      final val = UserBriefDto(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        nickname: $checkedConvert('nickname', (v) => v),
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserBriefDtoToJson(UserBriefDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt,
    };

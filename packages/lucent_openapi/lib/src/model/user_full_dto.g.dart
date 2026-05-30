// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_full_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserFullDto _$UserFullDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('UserFullDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'email',
          'nickname',
          'avatar',
          'emailVerified',
          'createdAt',
          'updatedAt',
        ],
      );
      final val = UserFullDto(
        id: $checkedConvert('id', (v) => v as String),
        email: $checkedConvert('email', (v) => v as String),
        nickname: $checkedConvert('nickname', (v) => v),
        avatar: $checkedConvert('avatar', (v) => v),
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
        createdAt: $checkedConvert('createdAt', (v) => v as String),
        updatedAt: $checkedConvert('updatedAt', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$UserFullDtoToJson(UserFullDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'avatar': instance.avatar,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

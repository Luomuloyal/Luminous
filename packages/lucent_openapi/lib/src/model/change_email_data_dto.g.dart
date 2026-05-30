// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeEmailDataDto _$ChangeEmailDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChangeEmailDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'emailVerified']);
      final val = ChangeEmailDataDto(
        email: $checkedConvert('email', (v) => v as String),
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$ChangeEmailDataDtoToJson(ChangeEmailDataDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'emailVerified': instance.emailVerified,
    };

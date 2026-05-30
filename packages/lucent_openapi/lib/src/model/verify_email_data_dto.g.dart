// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailDataDto _$VerifyEmailDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyEmailDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['emailVerified']);
      final val = VerifyEmailDataDto(
        emailVerified: $checkedConvert('emailVerified', (v) => v as bool),
      );
      return val;
    });

Map<String, dynamic> _$VerifyEmailDataDtoToJson(VerifyEmailDataDto instance) =>
    <String, dynamic>{'emailVerified': instance.emailVerified};

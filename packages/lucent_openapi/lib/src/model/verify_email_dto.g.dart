// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailDto _$VerifyEmailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('VerifyEmailDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'code']);
      final val = VerifyEmailDto(
        email: $checkedConvert('email', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$VerifyEmailDtoToJson(VerifyEmailDto instance) =>
    <String, dynamic>{'email': instance.email, 'code': instance.code};

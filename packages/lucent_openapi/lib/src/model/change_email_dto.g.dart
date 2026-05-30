// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeEmailDto _$ChangeEmailDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ChangeEmailDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['currentEmail', 'newEmail', 'code'],
      );
      final val = ChangeEmailDto(
        currentEmail: $checkedConvert('currentEmail', (v) => v as String),
        newEmail: $checkedConvert('newEmail', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$ChangeEmailDtoToJson(ChangeEmailDto instance) =>
    <String, dynamic>{
      'currentEmail': instance.currentEmail,
      'newEmail': instance.newEmail,
      'code': instance.code,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeleteAccountDto _$DeleteAccountDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DeleteAccountDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['password']);
      final val = DeleteAccountDto(
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DeleteAccountDtoToJson(DeleteAccountDto instance) =>
    <String, dynamic>{'password': instance.password};

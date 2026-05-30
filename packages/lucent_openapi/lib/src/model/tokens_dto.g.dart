// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tokens_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokensDto _$TokensDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TokensDto', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['accessToken', 'refreshToken', 'expiresIn'],
      );
      final val = TokensDto(
        accessToken: $checkedConvert('accessToken', (v) => v as String),
        refreshToken: $checkedConvert('refreshToken', (v) => v as String),
        expiresIn: $checkedConvert('expiresIn', (v) => v as num),
      );
      return val;
    });

Map<String, dynamic> _$TokensDtoToJson(TokensDto instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
};

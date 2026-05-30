// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterDataDto _$RegisterDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RegisterDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['user', 'tokens']);
      final val = RegisterDataDto(
        user: $checkedConvert(
          'user',
          (v) => UserBriefDto.fromJson(v as Map<String, dynamic>),
        ),
        tokens: $checkedConvert(
          'tokens',
          (v) => TokensDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$RegisterDataDtoToJson(RegisterDataDto instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tokens': instance.tokens.toJson(),
    };

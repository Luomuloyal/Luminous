// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_data_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginDataDto _$LoginDataDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginDataDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['user', 'tokens']);
      final val = LoginDataDto(
        user: $checkedConvert(
          'user',
          (v) => UserFullDto.fromJson(v as Map<String, dynamic>),
        ),
        tokens: $checkedConvert(
          'tokens',
          (v) => TokensDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$LoginDataDtoToJson(LoginDataDto instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tokens': instance.tokens.toJson(),
    };

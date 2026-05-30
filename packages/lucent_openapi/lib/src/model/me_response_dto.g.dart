// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MeResponseDto _$MeResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MeResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = MeResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert(
          'data',
          (v) => UserFullDto.fromJson(v as Map<String, dynamic>),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MeResponseDtoToJson(MeResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data.toJson(),
    };

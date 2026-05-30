// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessResponseDto _$SuccessResponseDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SuccessResponseDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
      final val = SuccessResponseDto(
        code: $checkedConvert('code', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
        data: $checkedConvert('data', (v) => v),
      );
      return val;
    });

Map<String, dynamic> _$SuccessResponseDtoToJson(SuccessResponseDto instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

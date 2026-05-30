// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_email_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChangeEmailResponseDto _$ChangeEmailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ChangeEmailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ChangeEmailResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => ChangeEmailDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ChangeEmailResponseDtoToJson(
  ChangeEmailResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};

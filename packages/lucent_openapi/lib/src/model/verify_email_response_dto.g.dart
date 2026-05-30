// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VerifyEmailResponseDto _$VerifyEmailResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('VerifyEmailResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = VerifyEmailResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => VerifyEmailDataDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$VerifyEmailResponseDtoToJson(
  VerifyEmailResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};

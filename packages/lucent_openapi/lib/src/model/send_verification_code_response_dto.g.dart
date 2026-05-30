// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_code_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendVerificationCodeResponseDto _$SendVerificationCodeResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SendVerificationCodeResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = SendVerificationCodeResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => CooldownMessageDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$SendVerificationCodeResponseDtoToJson(
  SendVerificationCodeResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};

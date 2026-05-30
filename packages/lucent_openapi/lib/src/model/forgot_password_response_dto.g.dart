// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResponseDto _$ForgotPasswordResponseDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('ForgotPasswordResponseDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['code', 'message', 'data']);
  final val = ForgotPasswordResponseDto(
    code: $checkedConvert('code', (v) => v as num),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => CooldownMessageDto.fromJson(v as Map<String, dynamic>),
    ),
  );
  return val;
});

Map<String, dynamic> _$ForgotPasswordResponseDtoToJson(
  ForgotPasswordResponseDto instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data.toJson(),
};

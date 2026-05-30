// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_verification_code_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SendVerificationCodeDto _$SendVerificationCodeDtoFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('SendVerificationCodeDto', json, ($checkedConvert) {
  $checkKeys(json, requiredKeys: const ['email', 'scene']);
  final val = SendVerificationCodeDto(
    email: $checkedConvert('email', (v) => v as String),
    scene: $checkedConvert(
      'scene',
      (v) => $enumDecode(
        _$SendVerificationCodeDtoSceneEnumEnumMap,
        v,
        unknownValue: SendVerificationCodeDtoSceneEnum.unknownDefaultOpenApi,
      ),
    ),
  );
  return val;
});

Map<String, dynamic> _$SendVerificationCodeDtoToJson(
  SendVerificationCodeDto instance,
) => <String, dynamic>{
  'email': instance.email,
  'scene': _$SendVerificationCodeDtoSceneEnumEnumMap[instance.scene]!,
};

const _$SendVerificationCodeDtoSceneEnumEnumMap = {
  SendVerificationCodeDtoSceneEnum.register: 'register',
  SendVerificationCodeDtoSceneEnum.login: 'login',
  SendVerificationCodeDtoSceneEnum.resetPassword: 'reset-password',
  SendVerificationCodeDtoSceneEnum.changeEmail: 'change-email',
  SendVerificationCodeDtoSceneEnum.unknownDefaultOpenApi:
      'unknown_default_open_api',
};

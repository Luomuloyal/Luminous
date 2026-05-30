// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cooldown_message_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CooldownMessageDto _$CooldownMessageDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CooldownMessageDto', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['cooldown', 'message']);
      final val = CooldownMessageDto(
        cooldown: $checkedConvert('cooldown', (v) => v as num),
        message: $checkedConvert('message', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CooldownMessageDtoToJson(CooldownMessageDto instance) =>
    <String, dynamic>{
      'cooldown': instance.cooldown,
      'message': instance.message,
    };

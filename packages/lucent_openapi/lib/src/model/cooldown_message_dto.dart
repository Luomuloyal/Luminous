//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'cooldown_message_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CooldownMessageDto {
  /// Returns a new [CooldownMessageDto] instance.
  CooldownMessageDto({

    required  this.cooldown,

    required  this.message,
  });

      /// 冷却时间（秒）
  @JsonKey(
    
    name: r'cooldown',
    required: true,
    includeIfNull: false,
  )


  final num cooldown;



      /// 提示消息
  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CooldownMessageDto &&
      other.cooldown == cooldown &&
      other.message == message;

    @override
    int get hashCode =>
        cooldown.hashCode +
        message.hashCode;

  factory CooldownMessageDto.fromJson(Map<String, dynamic> json) => _$CooldownMessageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CooldownMessageDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


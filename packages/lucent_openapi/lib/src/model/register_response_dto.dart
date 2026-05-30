//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/register_data_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'register_response_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RegisterResponseDto {
  /// Returns a new [RegisterResponseDto] instance.
  RegisterResponseDto({

    required  this.code,

    required  this.message,

    required  this.data,
  });

      /// 结果码
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final num code;



      /// 提示消息
  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: false,
  )


  final String message;



  @JsonKey(
    
    name: r'data',
    required: true,
    includeIfNull: false,
  )


  final RegisterDataDto data;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RegisterResponseDto &&
      other.code == code &&
      other.message == message &&
      other.data == data;

    @override
    int get hashCode =>
        code.hashCode +
        message.hashCode +
        data.hashCode;

  factory RegisterResponseDto.fromJson(Map<String, dynamic> json) => _$RegisterResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'reset_password_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ResetPasswordDto {
  /// Returns a new [ResetPasswordDto] instance.
  ResetPasswordDto({

    required  this.email,

    required  this.code,

    required  this.password,
  });

      /// 邮箱地址
  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



      /// 验证码
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;



      /// 新密码（8-32位，需包含大小写字母和数字）
  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ResetPasswordDto &&
      other.email == email &&
      other.code == code &&
      other.password == password;

    @override
    int get hashCode =>
        email.hashCode +
        code.hashCode +
        password.hashCode;

  factory ResetPasswordDto.fromJson(Map<String, dynamic> json) => _$ResetPasswordDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ResetPasswordDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


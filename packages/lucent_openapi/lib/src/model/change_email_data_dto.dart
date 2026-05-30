//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'change_email_data_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ChangeEmailDataDto {
  /// Returns a new [ChangeEmailDataDto] instance.
  ChangeEmailDataDto({

    required  this.email,

    required  this.emailVerified,
  });

      /// 新邮箱地址
  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



      /// 邮箱是否已验证
  @JsonKey(
    
    name: r'emailVerified',
    required: true,
    includeIfNull: false,
  )


  final bool emailVerified;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ChangeEmailDataDto &&
      other.email == email &&
      other.emailVerified == emailVerified;

    @override
    int get hashCode =>
        email.hashCode +
        emailVerified.hashCode;

  factory ChangeEmailDataDto.fromJson(Map<String, dynamic> json) => _$ChangeEmailDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ChangeEmailDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


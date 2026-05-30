//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:lucent_openapi/src/model/tokens_dto.dart';
import 'package:lucent_openapi/src/model/user_full_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_data_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginDataDto {
  /// Returns a new [LoginDataDto] instance.
  LoginDataDto({

    required  this.user,

    required  this.tokens,
  });

  @JsonKey(
    
    name: r'user',
    required: true,
    includeIfNull: false,
  )


  final UserFullDto user;



  @JsonKey(
    
    name: r'tokens',
    required: true,
    includeIfNull: false,
  )


  final TokensDto tokens;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LoginDataDto &&
      other.user == user &&
      other.tokens == tokens;

    @override
    int get hashCode =>
        user.hashCode +
        tokens.hashCode;

  factory LoginDataDto.fromJson(Map<String, dynamic> json) => _$LoginDataDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LoginDataDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


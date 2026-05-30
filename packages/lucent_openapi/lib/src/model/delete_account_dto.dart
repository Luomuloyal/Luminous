//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'delete_account_dto.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class DeleteAccountDto {
  /// Returns a new [DeleteAccountDto] instance.
  DeleteAccountDto({

    required  this.password,
  });

      /// 当前密码（确认注销）
  @JsonKey(
    
    name: r'password',
    required: true,
    includeIfNull: false,
  )


  final String password;





    @override
    bool operator ==(Object other) => identical(this, other) || other is DeleteAccountDto &&
      other.password == password;

    @override
    int get hashCode =>
        password.hashCode;

  factory DeleteAccountDto.fromJson(Map<String, dynamic> json) => _$DeleteAccountDtoFromJson(json);

  Map<String, dynamic> toJson() => _$DeleteAccountDtoToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


import 'package:lucent_openapi/src/model/change_email_data_dto.dart';
import 'package:lucent_openapi/src/model/change_email_dto.dart';
import 'package:lucent_openapi/src/model/change_email_response_dto.dart';
import 'package:lucent_openapi/src/model/change_password_dto.dart';
import 'package:lucent_openapi/src/model/cooldown_message_dto.dart';
import 'package:lucent_openapi/src/model/delete_account_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_dto.dart';
import 'package:lucent_openapi/src/model/forgot_password_response_dto.dart';
import 'package:lucent_openapi/src/model/login_data_dto.dart';
import 'package:lucent_openapi/src/model/login_dto.dart';
import 'package:lucent_openapi/src/model/login_response_dto.dart';
import 'package:lucent_openapi/src/model/logout_dto.dart';
import 'package:lucent_openapi/src/model/me_response_dto.dart';
import 'package:lucent_openapi/src/model/refresh_dto.dart';
import 'package:lucent_openapi/src/model/refresh_response_dto.dart';
import 'package:lucent_openapi/src/model/register_data_dto.dart';
import 'package:lucent_openapi/src/model/register_dto.dart';
import 'package:lucent_openapi/src/model/register_response_dto.dart';
import 'package:lucent_openapi/src/model/reset_password_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_dto.dart';
import 'package:lucent_openapi/src/model/send_verification_code_response_dto.dart';
import 'package:lucent_openapi/src/model/success_response_dto.dart';
import 'package:lucent_openapi/src/model/tokens_dto.dart';
import 'package:lucent_openapi/src/model/update_me_dto.dart';
import 'package:lucent_openapi/src/model/user_brief_dto.dart';
import 'package:lucent_openapi/src/model/user_full_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_data_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_dto.dart';
import 'package:lucent_openapi/src/model/verify_email_response_dto.dart';

final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ReturnType deserialize<ReturnType, BaseType>(
  dynamic value,
  String targetType, {
  bool growable = true,
}) {
  switch (targetType) {
    case 'String':
      return '$value' as ReturnType;
    case 'int':
      return (value is int ? value : int.parse('$value')) as ReturnType;
    case 'bool':
      if (value is bool) {
        return value as ReturnType;
      }
      final valueString = '$value'.toLowerCase();
      return (valueString == 'true' || valueString == '1') as ReturnType;
    case 'double':
      return (value is double ? value : double.parse('$value')) as ReturnType;
    case 'ChangeEmailDataDto':
      return ChangeEmailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangeEmailDto':
      return ChangeEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangeEmailResponseDto':
      return ChangeEmailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ChangePasswordDto':
      return ChangePasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'CooldownMessageDto':
      return CooldownMessageDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'DeleteAccountDto':
      return DeleteAccountDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordDto':
      return ForgotPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ForgotPasswordResponseDto':
      return ForgotPasswordResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LoginDataDto':
      return LoginDataDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginDto':
      return LoginDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'LoginResponseDto':
      return LoginResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'LogoutDto':
      return LogoutDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'MeResponseDto':
      return MeResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RefreshDto':
      return RefreshDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RefreshResponseDto':
      return RefreshResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterDataDto':
      return RegisterDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'RegisterDto':
      return RegisterDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'RegisterResponseDto':
      return RegisterResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'ResetPasswordDto':
      return ResetPasswordDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeDto':
      return SendVerificationCodeDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'SendVerificationCodeResponseDto':
      return SendVerificationCodeResponseDto.fromJson(
            value as Map<String, dynamic>,
          )
          as ReturnType;
    case 'SuccessResponseDto':
      return SuccessResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'TokensDto':
      return TokensDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UpdateMeDto':
      return UpdateMeDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserBriefDto':
      return UserBriefDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'UserFullDto':
      return UserFullDto.fromJson(value as Map<String, dynamic>) as ReturnType;
    case 'VerifyEmailDataDto':
      return VerifyEmailDataDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailDto':
      return VerifyEmailDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    case 'VerifyEmailResponseDto':
      return VerifyEmailResponseDto.fromJson(value as Map<String, dynamic>)
          as ReturnType;
    default:
      RegExpMatch? match;

      if (value is List && (match = _regList.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toList(growable: growable)
            as ReturnType;
      }
      if (value is Set && (match = _regSet.firstMatch(targetType)) != null) {
        targetType = match![1]!; // ignore: parameter_assignments
        return value
                .map<BaseType>(
                  (dynamic v) => deserialize<BaseType, BaseType>(
                    v,
                    targetType,
                    growable: growable,
                  ),
                )
                .toSet()
            as ReturnType;
      }
      if (value is Map && (match = _regMap.firstMatch(targetType)) != null) {
        targetType = match![1]!.trim(); // ignore: parameter_assignments
        return Map<String, BaseType>.fromIterables(
              value.keys as Iterable<String>,
              value.values.map(
                (dynamic v) => deserialize<BaseType, BaseType>(
                  v,
                  targetType,
                  growable: growable,
                ),
              ),
            )
            as ReturnType;
      }
      break;
  }
  throw Exception('Cannot deserialize');
}

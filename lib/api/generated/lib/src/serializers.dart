//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_import

import 'package:one_of_serializer/any_of_serializer.dart';
import 'package:one_of_serializer/one_of_serializer.dart';
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:luminous_api/src/date_serializer.dart';
import 'package:luminous_api/src/model/date.dart';

import 'package:luminous_api/src/model/change_email_data_dto.dart';
import 'package:luminous_api/src/model/change_email_dto.dart';
import 'package:luminous_api/src/model/change_email_response_dto.dart';
import 'package:luminous_api/src/model/change_password_dto.dart';
import 'package:luminous_api/src/model/cooldown_message_dto.dart';
import 'package:luminous_api/src/model/delete_account_dto.dart';
import 'package:luminous_api/src/model/forgot_password_dto.dart';
import 'package:luminous_api/src/model/forgot_password_response_dto.dart';
import 'package:luminous_api/src/model/login_data_dto.dart';
import 'package:luminous_api/src/model/login_dto.dart';
import 'package:luminous_api/src/model/login_response_dto.dart';
import 'package:luminous_api/src/model/logout_dto.dart';
import 'package:luminous_api/src/model/me_response_dto.dart';
import 'package:luminous_api/src/model/refresh_dto.dart';
import 'package:luminous_api/src/model/refresh_response_dto.dart';
import 'package:luminous_api/src/model/register_data_dto.dart';
import 'package:luminous_api/src/model/register_dto.dart';
import 'package:luminous_api/src/model/register_response_dto.dart';
import 'package:luminous_api/src/model/reset_password_dto.dart';
import 'package:luminous_api/src/model/send_verification_code_dto.dart';
import 'package:luminous_api/src/model/send_verification_code_response_dto.dart';
import 'package:luminous_api/src/model/success_response_dto.dart';
import 'package:luminous_api/src/model/tokens_dto.dart';
import 'package:luminous_api/src/model/update_me_dto.dart';
import 'package:luminous_api/src/model/user_brief_dto.dart';
import 'package:luminous_api/src/model/user_full_dto.dart';
import 'package:luminous_api/src/model/verify_email_data_dto.dart';
import 'package:luminous_api/src/model/verify_email_dto.dart';
import 'package:luminous_api/src/model/verify_email_response_dto.dart';

part 'serializers.g.dart';

@SerializersFor([
  ChangeEmailDataDto,
  ChangeEmailDto,
  ChangeEmailResponseDto,
  ChangePasswordDto,
  CooldownMessageDto,
  DeleteAccountDto,
  ForgotPasswordDto,
  ForgotPasswordResponseDto,
  LoginDataDto,
  LoginDto,
  LoginResponseDto,
  LogoutDto,
  MeResponseDto,
  RefreshDto,
  RefreshResponseDto,
  RegisterDataDto,
  RegisterDto,
  RegisterResponseDto,
  ResetPasswordDto,
  SendVerificationCodeDto,
  SendVerificationCodeResponseDto,
  SuccessResponseDto,
  TokensDto,
  UpdateMeDto,
  UserBriefDto,
  UserFullDto,
  VerifyEmailDataDto,
  VerifyEmailDto,
  VerifyEmailResponseDto,
])
Serializers serializers = (_$serializers.toBuilder()
      ..add(const OneOfSerializer())
      ..add(const AnyOfSerializer())
      ..add(const DateSerializer())
      ..add(Iso8601DateTimeSerializer())
    ).build();

Serializers standardSerializers =
    (serializers.toBuilder()..addPlugin(StandardJsonPlugin())).build();

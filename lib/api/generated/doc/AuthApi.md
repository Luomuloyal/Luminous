# luminous_api.api.AuthApi

## Load the API package
```dart
import 'package:luminous_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**authControllerChangeEmailV1**](AuthApi.md#authcontrollerchangeemailv1) | **POST** /api/v1/auth/me/email | 修改邮箱
[**authControllerChangePasswordV1**](AuthApi.md#authcontrollerchangepasswordv1) | **POST** /api/v1/auth/me/password | 修改密码
[**authControllerDeleteAccountV1**](AuthApi.md#authcontrollerdeleteaccountv1) | **DELETE** /api/v1/auth/me | 注销账户
[**authControllerForgotPasswordV1**](AuthApi.md#authcontrollerforgotpasswordv1) | **POST** /api/v1/auth/forgot-password | 忘记密码
[**authControllerGetMeV1**](AuthApi.md#authcontrollergetmev1) | **GET** /api/v1/auth/me | 获取当前用户信息
[**authControllerLoginV1**](AuthApi.md#authcontrollerloginv1) | **POST** /api/v1/auth/login | 用户登录
[**authControllerLogoutV1**](AuthApi.md#authcontrollerlogoutv1) | **POST** /api/v1/auth/logout | 用户登出
[**authControllerRefreshV1**](AuthApi.md#authcontrollerrefreshv1) | **POST** /api/v1/auth/refresh | 刷新令牌
[**authControllerRegisterV1**](AuthApi.md#authcontrollerregisterv1) | **POST** /api/v1/auth/register | 用户注册
[**authControllerResetPasswordV1**](AuthApi.md#authcontrollerresetpasswordv1) | **POST** /api/v1/auth/reset-password | 重置密码
[**authControllerSendVerificationCodeV1**](AuthApi.md#authcontrollersendverificationcodev1) | **POST** /api/v1/auth/send-verification-code | 发送邮箱验证码
[**authControllerUpdateMeV1**](AuthApi.md#authcontrollerupdatemev1) | **PATCH** /api/v1/auth/me | 更新当前用户信息
[**authControllerVerifyEmailV1**](AuthApi.md#authcontrollerverifyemailv1) | **POST** /api/v1/auth/verify-email | 验证邮箱


# **authControllerChangeEmailV1**
> ChangeEmailResponseDto authControllerChangeEmailV1(changeEmailDto)

修改邮箱

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final ChangeEmailDto changeEmailDto = ; // ChangeEmailDto | 

try {
    final response = api.authControllerChangeEmailV1(changeEmailDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerChangeEmailV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changeEmailDto** | [**ChangeEmailDto**](ChangeEmailDto.md)|  | 

### Return type

[**ChangeEmailResponseDto**](ChangeEmailResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerChangePasswordV1**
> SuccessResponseDto authControllerChangePasswordV1(changePasswordDto)

修改密码

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final ChangePasswordDto changePasswordDto = ; // ChangePasswordDto | 

try {
    final response = api.authControllerChangePasswordV1(changePasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerChangePasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **changePasswordDto** | [**ChangePasswordDto**](ChangePasswordDto.md)|  | 

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerDeleteAccountV1**
> SuccessResponseDto authControllerDeleteAccountV1(deleteAccountDto)

注销账户

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final DeleteAccountDto deleteAccountDto = ; // DeleteAccountDto | 

try {
    final response = api.authControllerDeleteAccountV1(deleteAccountDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerDeleteAccountV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **deleteAccountDto** | [**DeleteAccountDto**](DeleteAccountDto.md)|  | 

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerForgotPasswordV1**
> ForgotPasswordResponseDto authControllerForgotPasswordV1(forgotPasswordDto)

忘记密码

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final ForgotPasswordDto forgotPasswordDto = ; // ForgotPasswordDto | 

try {
    final response = api.authControllerForgotPasswordV1(forgotPasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerForgotPasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **forgotPasswordDto** | [**ForgotPasswordDto**](ForgotPasswordDto.md)|  | 

### Return type

[**ForgotPasswordResponseDto**](ForgotPasswordResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerGetMeV1**
> MeResponseDto authControllerGetMeV1()

获取当前用户信息

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();

try {
    final response = api.authControllerGetMeV1();
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerGetMeV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

[**MeResponseDto**](MeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLoginV1**
> LoginResponseDto authControllerLoginV1(loginDto)

用户登录

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final LoginDto loginDto = ; // LoginDto | 

try {
    final response = api.authControllerLoginV1(loginDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLoginV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **loginDto** | [**LoginDto**](LoginDto.md)|  | 

### Return type

[**LoginResponseDto**](LoginResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerLogoutV1**
> SuccessResponseDto authControllerLogoutV1(logoutDto)

用户登出

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final LogoutDto logoutDto = ; // LogoutDto | 

try {
    final response = api.authControllerLogoutV1(logoutDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerLogoutV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **logoutDto** | [**LogoutDto**](LogoutDto.md)|  | 

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRefreshV1**
> RefreshResponseDto authControllerRefreshV1(refreshDto)

刷新令牌

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final RefreshDto refreshDto = ; // RefreshDto | 

try {
    final response = api.authControllerRefreshV1(refreshDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRefreshV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **refreshDto** | [**RefreshDto**](RefreshDto.md)|  | 

### Return type

[**RefreshResponseDto**](RefreshResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerRegisterV1**
> RegisterResponseDto authControllerRegisterV1(registerDto)

用户注册

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final RegisterDto registerDto = ; // RegisterDto | 

try {
    final response = api.authControllerRegisterV1(registerDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerRegisterV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **registerDto** | [**RegisterDto**](RegisterDto.md)|  | 

### Return type

[**RegisterResponseDto**](RegisterResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerResetPasswordV1**
> SuccessResponseDto authControllerResetPasswordV1(resetPasswordDto)

重置密码

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final ResetPasswordDto resetPasswordDto = ; // ResetPasswordDto | 

try {
    final response = api.authControllerResetPasswordV1(resetPasswordDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerResetPasswordV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **resetPasswordDto** | [**ResetPasswordDto**](ResetPasswordDto.md)|  | 

### Return type

[**SuccessResponseDto**](SuccessResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerSendVerificationCodeV1**
> SendVerificationCodeResponseDto authControllerSendVerificationCodeV1(sendVerificationCodeDto)

发送邮箱验证码

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final SendVerificationCodeDto sendVerificationCodeDto = ; // SendVerificationCodeDto | 

try {
    final response = api.authControllerSendVerificationCodeV1(sendVerificationCodeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerSendVerificationCodeV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **sendVerificationCodeDto** | [**SendVerificationCodeDto**](SendVerificationCodeDto.md)|  | 

### Return type

[**SendVerificationCodeResponseDto**](SendVerificationCodeResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerUpdateMeV1**
> MeResponseDto authControllerUpdateMeV1(updateMeDto)

更新当前用户信息

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final UpdateMeDto updateMeDto = ; // UpdateMeDto | 

try {
    final response = api.authControllerUpdateMeV1(updateMeDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerUpdateMeV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **updateMeDto** | [**UpdateMeDto**](UpdateMeDto.md)|  | 

### Return type

[**MeResponseDto**](MeResponseDto.md)

### Authorization

[access-token](../README.md#access-token)

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **authControllerVerifyEmailV1**
> VerifyEmailResponseDto authControllerVerifyEmailV1(verifyEmailDto)

验证邮箱

### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAuthApi();
final VerifyEmailDto verifyEmailDto = ; // VerifyEmailDto | 

try {
    final response = api.authControllerVerifyEmailV1(verifyEmailDto);
    print(response);
} on DioException catch (e) {
    print('Exception when calling AuthApi->authControllerVerifyEmailV1: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **verifyEmailDto** | [**VerifyEmailDto**](VerifyEmailDto.md)|  | 

### Return type

[**VerifyEmailResponseDto**](VerifyEmailResponseDto.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


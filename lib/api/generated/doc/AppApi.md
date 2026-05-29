# luminous_api.api.AppApi

## Load the API package
```dart
import 'package:luminous_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**appControllerGetHealthV1**](AppApi.md#appcontrollergethealthv1) | **GET** /api/v1/health | 


# **appControllerGetHealthV1**
> appControllerGetHealthV1()



### Example
```dart
import 'package:luminous_api/api.dart';

final api = LuminousApi().getAppApi();

try {
    api.appControllerGetHealthV1();
} on DioException catch (e) {
    print('Exception when calling AppApi->appControllerGetHealthV1: $e\n');
}
```

### Parameters
This endpoint does not need any parameter.

### Return type

void (empty response body)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: Not defined

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)


import 'package:luminous/constants/constants.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/viewmodels/auth.dart';

/// 用户资料相关接口封装。
class UserApi {
  const UserApi();

  /// 读取个人资料。
  Future<ApiResult<UserSafe>> getProfile({required String userId}) {
    return dioRequest.post<UserSafe>(
      HttpConstants.USER_PROFILE,
      data: {'userId': userId.trim()},
      decoder: (json) => UserSafe.fromJson(_asMap(json)),
    );
  }

  /// 保存个人资料。
  Future<ApiResult<UserSafe>> updateProfile({
    required String userId,
    required String avatar,
    required String nickname,
    required String gender,
    required String birthday,
    required String profession,
    required String provinceCode,
    required String cityCode,
  }) {
    return dioRequest.post<UserSafe>(
      HttpConstants.USER_PROFILE_UPDATE,
      data: {
        'userId': userId.trim(),
        'avatar': avatar.trim(),
        'nickname': nickname.trim(),
        'gender': gender.trim(),
        'birthday': birthday.trim(),
        'profession': profession.trim(),
        'provinceCode': provinceCode.trim(),
        'cityCode': cityCode.trim(),
      },
      showLoading: true,
      loadingText: AppI18nText.pick(zh: '保存中...', en: 'Saving...'),
      decoder: (json) => UserSafe.fromJson(_asMap(json)),
    );
  }

  static Map<String, dynamic> _asMap(dynamic json) {
    if (json is Map<String, dynamic>) {
      return json;
    }
    if (json is Map) {
      return json.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}

const userApi = UserApi();

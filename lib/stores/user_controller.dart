import 'dart:convert';

import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 全局用户态控制器。
///
/// 使用 GetX 管理当前登录用户，并负责和本地持久化做同步。
class UserController extends GetxController {
  /// 当前登录用户的响应式容器。
  ///
  /// 未登录时值为 `null`，已登录时保存 `UserSafe`。
  final Rxn<UserSafe> user = Rxn<UserSafe>();

  /// 当前是否处于登录状态。
  ///
  /// 通过用户对象是否存在且有有效数据来判断。
  bool get isLoggedIn => user.value?.hasData ?? false;

  /// 从本地缓存恢复登录用户。
  ///
  /// 应用启动时由 `main()` 调用一次。
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    /// 本地缓存的用户 JSON 字符串。
    final rawUser = prefs.getString(GlobalConstants.USER_KEY);

    if (rawUser == null || rawUser.trim().isEmpty) {
      user.value = null;
      return;
    }

    try {
      /// 从本地字符串反序列化得到的 JSON 对象。
      final decoded = jsonDecode(rawUser);
      if (decoded is Map<String, dynamic>) {
        user.value = UserSafe.fromJson(decoded);
        return;
      }
    } catch (_) {
      await prefs.remove(GlobalConstants.USER_KEY);
    }

    user.value = null;
  }

  /// 更新当前用户并持久化到本地。
  ///
  /// 一般在登录成功后调用。
  Future<void> setUser(UserSafe nextUser) async {
    user.value = nextUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      GlobalConstants.USER_KEY,
      jsonEncode(nextUser.toJson()),
    );
  }

  /// 清空当前用户状态并删除本地持久化数据。
  ///
  /// 一般在主动退出登录时调用。
  Future<void> logout() async {
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GlobalConstants.USER_KEY);
  }
}

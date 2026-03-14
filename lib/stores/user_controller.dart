import 'dart:convert';

import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// UserController：全局用户态（GetX）。
//
// 设计思路：
// - UI 只读 user / isLoggedIn，不直接操作 SharedPreferences
// - 登录成功时 setUser，退出时 logout
// - init 在 main() 中执行，用于应用启动恢复登录态
//
// 注意：
// - 当前阶段未接 token（仅保存 safeUser），后续接 token 时可扩展字段与持久化逻辑
// - widget test 中不会走 main()，需要在测试里 Get.put(UserController) 并 setMockInitialValues
class UserController extends GetxController {
  final Rxn<UserSafe> user = Rxn<UserSafe>();

  bool get isLoggedIn => user.value?.hasData ?? false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(GlobalConstants.USER_KEY);

    if (rawUser == null || rawUser.trim().isEmpty) {
      user.value = null;
      return;
    }

    try {
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

  Future<void> setUser(UserSafe nextUser) async {
    user.value = nextUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      GlobalConstants.USER_KEY,
      jsonEncode(nextUser.toJson()),
    );
  }

  Future<void> logout() async {
    user.value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(GlobalConstants.USER_KEY);
  }
}

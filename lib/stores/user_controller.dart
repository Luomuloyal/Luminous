import 'dart:convert';

import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

import 'dart:convert';

import 'package:luminous/constants/constants.dart';
import 'package:luminous/viewmodels/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSessionStore {
  UserSessionStore._(this._prefsFuture);

  factory UserSessionStore.fromPreferences(SharedPreferences prefs) {
    return UserSessionStore._(Future<SharedPreferences>.value(prefs));
  }

  factory UserSessionStore.lazy() {
    return UserSessionStore._(SharedPreferences.getInstance());
  }

  final Future<SharedPreferences> _prefsFuture;

  Future<UserSafe?> restoreUser() async {
    final prefs = await _prefsFuture;
    final rawUser = prefs.getString(GlobalConstants.USER_KEY);

    if (rawUser == null || rawUser.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawUser);
      if (decoded is Map) {
        return UserSafe.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Invalid cached sessions are cleared below and treated as logged out.
    }

    await prefs.remove(GlobalConstants.USER_KEY);
    return null;
  }

  Future<void> persistUser(UserSafe user) async {
    final prefs = await _prefsFuture;
    await prefs.setString(GlobalConstants.USER_KEY, jsonEncode(user.toJson()));
  }

  Future<void> clearUser() async {
    final prefs = await _prefsFuture;
    await prefs.remove(GlobalConstants.USER_KEY);
  }
}

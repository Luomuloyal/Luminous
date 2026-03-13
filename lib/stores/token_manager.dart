import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<void> init() async {
    await _prefs;
  }

  Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(GlobalConstants.tokenKey, token);
  }

  Future<String> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(GlobalConstants.tokenKey) ?? '';
  }

  Future<void> deleteToken() async {
    final prefs = await _prefs;
    await prefs.remove(GlobalConstants.tokenKey);
  }
}

final tokenManager = TokenManager();

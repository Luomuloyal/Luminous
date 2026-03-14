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
    await prefs.setString(GlobalConstants.TOKEN_KEY, token);
  }

  Future<String> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(GlobalConstants.TOKEN_KEY) ?? '';
  }

  Future<void> deleteToken() async {
    final prefs = await _prefs;
    await prefs.remove(GlobalConstants.TOKEN_KEY);
  }
}

final tokenManager = TokenManager();

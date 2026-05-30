import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LucentSessionTokens {
  const LucentSessionTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;

  bool get hasAccessToken => accessToken.trim().isNotEmpty;

  bool get hasRefreshToken => refreshToken.trim().isNotEmpty;
}

abstract interface class LucentSessionStore {
  Future<LucentSessionTokens?> read();

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> write(LucentSessionTokens tokens);

  Future<void> clear();
}

class SharedPrefsLucentSessionStore implements LucentSessionStore {
  const SharedPrefsLucentSessionStore();

  static const String accessTokenKey = 'lucent_access_token';
  static const String refreshTokenKey = 'lucent_refresh_token';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  @override
  Future<void> clear() async {
    final prefs = await _prefs();
    await prefs.remove(accessTokenKey);
    await prefs.remove(refreshTokenKey);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    final prefs = await _prefs();
    final accessToken = prefs.getString(accessTokenKey)?.trim() ?? '';
    final refreshToken = prefs.getString(refreshTokenKey)?.trim() ?? '';
    if (accessToken.isEmpty && refreshToken.isEmpty) {
      return null;
    }
    return LucentSessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<String?> readAccessToken() async {
    final prefs = await _prefs();
    final token = prefs.getString(accessTokenKey)?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  @override
  Future<String?> readRefreshToken() async {
    final prefs = await _prefs();
    final token = prefs.getString(refreshTokenKey)?.trim() ?? '';
    return token.isEmpty ? null : token;
  }

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    final prefs = await _prefs();
    await prefs.setString(accessTokenKey, tokens.accessToken.trim());
    await prefs.setString(refreshTokenKey, tokens.refreshToken.trim());
  }
}

class SecureLucentSessionStore implements LucentSessionStore {
  const SecureLucentSessionStore({
    FlutterSecureStorage? storage,
    SharedPrefsLucentSessionStore? fallbackStore,
  }) : _storage = storage ?? const FlutterSecureStorage(),
       _fallbackStore = fallbackStore ?? const SharedPrefsLucentSessionStore();

  final FlutterSecureStorage _storage;
  final SharedPrefsLucentSessionStore _fallbackStore;

  bool get _useFallback {
    return kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Future<void> clear() async {
    if (_useFallback) {
      await _fallbackStore.clear();
      return;
    }
    await _storage.delete(key: SharedPrefsLucentSessionStore.accessTokenKey);
    await _storage.delete(key: SharedPrefsLucentSessionStore.refreshTokenKey);
  }

  @override
  Future<LucentSessionTokens?> read() async {
    if (_useFallback) {
      return _fallbackStore.read();
    }

    final accessToken =
        (await _storage.read(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
        ))?.trim() ??
        '';
    final refreshToken =
        (await _storage.read(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
        ))?.trim() ??
        '';

    if (accessToken.isEmpty && refreshToken.isEmpty) {
      return null;
    }

    return LucentSessionTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<String?> readAccessToken() async {
    if (_useFallback) {
      return _fallbackStore.readAccessToken();
    }
    final token =
        (await _storage.read(
          key: SharedPrefsLucentSessionStore.accessTokenKey,
        ))?.trim() ??
        '';
    return token.isEmpty ? null : token;
  }

  @override
  Future<String?> readRefreshToken() async {
    if (_useFallback) {
      return _fallbackStore.readRefreshToken();
    }
    final token =
        (await _storage.read(
          key: SharedPrefsLucentSessionStore.refreshTokenKey,
        ))?.trim() ??
        '';
    return token.isEmpty ? null : token;
  }

  @override
  Future<void> write(LucentSessionTokens tokens) async {
    if (_useFallback) {
      await _fallbackStore.write(tokens);
      return;
    }
    await _storage.write(
      key: SharedPrefsLucentSessionStore.accessTokenKey,
      value: tokens.accessToken.trim(),
    );
    await _storage.write(
      key: SharedPrefsLucentSessionStore.refreshTokenKey,
      value: tokens.refreshToken.trim(),
    );
  }
}

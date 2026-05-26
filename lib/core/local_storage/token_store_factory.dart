import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'flutter_secure_token_store.dart';
import 'secure_token_store.dart';
import 'shared_prefs_token_store.dart';

/// Create a [SecureTokenStore] appropriate for the current platform.
///
/// | Platform      | Implementation                     |
/// |---------------|------------------------------------|
/// | Android / iOS | [FlutterSecureTokenStore]          |
/// | macOS         | [FlutterSecureTokenStore]          |
/// | Web           | [SharedPrefsTokenStore]            |
/// | Windows/Linux | [SharedPrefsTokenStore]            |
///
/// On mobile platforms, this uses the OS-level encrypted storage
/// (Android Keystore / iOS Keychain / macOS Keychain).
///
/// Web and desktop fall back to [SharedPreferences] because
/// `flutter_secure_storage` does not support those platforms.
SecureTokenStore createPlatformTokenStore() {
  if (kIsWeb) {
    // Web: flutter_secure_storage throws at runtime.
    // We intentionally use SharedPreferences (plain-text) and document
    // the limitation — Step 15 note explicitly allows this.
    return _DeferredSharedPrefsTokenStore();
  }
  return FlutterSecureTokenStore();
}

/// Lazily initialises [SharedPrefsTokenStore] on first access.
///
/// We avoid calling `SharedPreferences.getInstance()` eagerly at module
/// load time because it requires the Flutter engine to be initialised.
class _DeferredSharedPrefsTokenStore implements SecureTokenStore {
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<String?> read(String key) async =>
      (await _instance).getString(key);

  @override
  Future<void> write(String key, String value) async =>
      (await _instance).setString(key, value);

  @override
  Future<void> delete(String key) async =>
      (await _instance).remove(key);

  @override
  Future<bool> containsKey(String key) async =>
      (await _instance).containsKey(key);
}

import 'package:shared_preferences/shared_preferences.dart';

import 'secure_token_store.dart';

/// [SecureTokenStore] backed by [SharedPreferences].
///
/// Primary use-cases:
/// - **Web** where `flutter_secure_storage` is unsupported.
/// - **Desktop** (Windows/Linux) as a lightweight fallback.
/// - **Tests** where a fake / in-memory store is easier to control.
///
/// ⚠️ Values are stored in plain text — not suitable for production
/// mobile apps. Prefer [FlutterSecureTokenStore] on Android / iOS.
class SharedPrefsTokenStore implements SecureTokenStore {
  final SharedPreferences _prefs;

  /// Wrap an existing [SharedPreferences] instance.
  ///
  /// Callers are responsible for obtaining `SharedPreferences` before
  /// constructing this store (e.g. via `SharedPreferences.getInstance()`).
  SharedPrefsTokenStore(this._prefs);

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);
}

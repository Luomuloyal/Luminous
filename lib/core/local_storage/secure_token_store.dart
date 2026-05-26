/// Abstract token storage interface.
///
/// Implementations:
/// - [FlutterSecureTokenStore] — platform-encrypted (Android Keystore / iOS Keychain).
/// - [SharedPrefsTokenStore] — SharedPreferences fallback (Web, desktop, or test).
abstract class SecureTokenStore {
  /// Read a value by [key]. Returns `null` if absent.
  Future<String?> read(String key);

  /// Persist [value] under [key].
  Future<void> write(String key, String value);

  /// Remove the entry identified by [key].
  Future<void> delete(String key);

  /// Whether a value exists for [key].
  Future<bool> containsKey(String key);
}

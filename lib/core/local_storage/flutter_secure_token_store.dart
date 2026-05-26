import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_token_store.dart';

/// [SecureTokenStore] backed by platform-encrypted storage.
///
/// Android: EncryptedSharedPreferences + Android Keystore.
/// iOS / macOS: Keychain.
/// Linux: libsecret.
/// Web: **not supported** — `FlutterSecureStorage` throws at runtime on Web;
/// use [SharedPrefsTokenStore] as a web fallback instead.
class FlutterSecureTokenStore implements SecureTokenStore {
  final FlutterSecureStorage _storage;

  /// Create with default [FlutterSecureStorage] options.
  FlutterSecureTokenStore()
    : _storage = const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<bool> containsKey(String key) =>
      _storage.containsKey(key: key);
}

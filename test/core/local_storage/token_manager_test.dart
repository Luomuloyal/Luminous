import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/core/local_storage/secure_token_store.dart';
import 'package:luminous/core/local_storage/token_manager.dart';

/// In-memory [SecureTokenStore] for tests.
class _FakeSecureTokenStore implements SecureTokenStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Future<bool> containsKey(String key) async => _data.containsKey(key);
}

void main() {
  late _FakeSecureTokenStore store;
  late TokenManager manager;

  setUp(() {
    store = _FakeSecureTokenStore();
    manager = TokenManager(store: store);
  });

  group('TokenManager', () {
    test('init marks migrated to skip SharedPreferences check', () async {
      await manager.init();
      // Second init should be a no-op (no SharedPreferences in test env)
      await manager.init();
      // No exception → pass
    });

    test('setToken writes to store', () async {
      await manager.setToken('access-123');
      expect(await manager.getToken(), 'access-123');
    });

    test('setToken with empty string deletes from store', () async {
      await manager.setToken('access-123');
      await manager.setToken('');
      expect(await manager.getToken(), '');
      expect(await store.containsKey('luminous_access_token'), isFalse);
    });

    test('setRefreshToken writes to store', () async {
      await manager.setRefreshToken('refresh-456');
      expect(await manager.getRefreshToken(), 'refresh-456');
    });

    test('setRefreshToken with empty string deletes', () async {
      await manager.setRefreshToken('refresh-456');
      await manager.setRefreshToken('');
      expect(await manager.getRefreshToken(), '');
    });

    test('getToken returns empty string when absent', () async {
      expect(await manager.getToken(), '');
    });

    test('getRefreshToken returns empty string when absent', () async {
      expect(await manager.getRefreshToken(), '');
    });

    test('deleteToken removes both tokens', () async {
      await manager.setToken('access-123');
      await manager.setRefreshToken('refresh-456');
      await manager.deleteToken();

      expect(await manager.getToken(), '');
      expect(await manager.getRefreshToken(), '');
    });

    test('tokens survive across reads', () async {
      await manager.setToken('at');
      await manager.setRefreshToken('rt');

      // Read multiple times
      expect(await manager.getToken(), 'at');
      expect(await manager.getToken(), 'at');
      expect(await manager.getRefreshToken(), 'rt');
    });
  });
}

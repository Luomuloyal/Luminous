import 'package:shared_preferences/shared_preferences.dart';

import 'package:luminous/core/local_storage/secure_token_store.dart';
import 'package:luminous/core/local_storage/token_store_factory.dart';

/// Token 持久化管理器。
///
/// 封装 [SecureTokenStore]，提供 access / refresh token 的读写删接口。
/// 首次初始化时自动从旧版 [SharedPreferences] 迁移 token 到安全存储。
class TokenManager {
  final SecureTokenStore _store;

  /// 创建 [TokenManager] 实例。
  ///
  /// 默认使用平台自适应的 [SecureTokenStore] 实现：
  /// - Android / iOS / macOS → 系统级加密存储
  /// - Web / 桌面 → SharedPreferences fallback
  TokenManager({SecureTokenStore? store})
    : _store = store ?? createPlatformTokenStore();

  // ── Key constants ────────────────────────────────────────────

  static const String _accessTokenKey = 'luminous_access_token';
  static const String _refreshTokenKey = 'luminous_refresh_token';

  // ── 迁移 ──────────────────────────────────────────────────────

  bool _migrated = false;

  /// 预初始化本地存储，并执行首次 token 迁移。
  ///
  /// 当前实现：
  /// 1. 如果未迁移过，检查 SharedPreferences 中是否有旧 token；
  /// 2. 若有，复制到 [SecureTokenStore] 并从 SharedPreferences 删除；
  /// 3. 仅首次 init 时执行迁移，后续调用无额外开销。
  Future<void> init() async {
    if (_migrated) return;
    _migrated = true;
    await _migrateFromSharedPrefsIfNeeded();
  }

  Future<void> _migrateFromSharedPrefsIfNeeded() async {
    try {
      final alreadyMigrated = await _store.containsKey(_accessTokenKey);
      if (alreadyMigrated) return;

      final prefs = await SharedPreferences.getInstance();
      final oldAccess = prefs.getString(_accessTokenKey);
      final oldRefresh = prefs.getString(_refreshTokenKey);

      if (oldAccess != null && oldAccess.isNotEmpty) {
        await _store.write(_accessTokenKey, oldAccess);
      }
      if (oldRefresh != null && oldRefresh.isNotEmpty) {
        await _store.write(_refreshTokenKey, oldRefresh);
      }
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {
      // Migration is best-effort — if SharedPreferences or secure storage
      // is unavailable (e.g. in tests without binding), we skip silently.
    }
  }

  // ── Token 操作 ────────────────────────────────────────────────

  /// 持久化保存 access token。
  Future<void> setToken(String token) async {
    if (token.isEmpty) {
      await _store.delete(_accessTokenKey);
    } else {
      await _store.write(_accessTokenKey, token);
    }
  }

  /// 持久化保存 refresh token。
  Future<void> setRefreshToken(String token) async {
    if (token.isEmpty) {
      await _store.delete(_refreshTokenKey);
    } else {
      await _store.write(_refreshTokenKey, token);
    }
  }

  /// 读取本地缓存的 access token。
  ///
  /// 如果本地没有 token，则返回空字符串。
  Future<String> getToken() async {
    return await _store.read(_accessTokenKey) ?? '';
  }

  /// 读取本地缓存的 refresh token。
  Future<String> getRefreshToken() async {
    return await _store.read(_refreshTokenKey) ?? '';
  }

  /// 删除本地缓存的 tokens。
  ///
  /// 一般在退出登录或 token 失效时调用。
  Future<void> deleteToken() async {
    await _store.delete(_accessTokenKey);
    await _store.delete(_refreshTokenKey);
  }
}

/// TokenManager 的全局单例入口。
///
/// 默认使用平台自适应的安全存储实现。
final tokenManager = TokenManager();

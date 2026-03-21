import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Token 持久化管理器。
///
/// 当前项目虽然还未完整启用 token 鉴权，但已经预留了统一的读写入口。
class TokenManager {
  Future<SharedPreferences>? _prefsFuture;

  /// 获取 `SharedPreferences` 实例。
  ///
  /// 通过 getter 统一封装，便于后续在一个地方调整存储实现。
  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  /// 预初始化本地存储。
  ///
  /// 当前实现只是提前拿一次 `SharedPreferences`，便于在应用启动时完成依赖预热。
  Future<void> init() async {
    await _prefs;
  }

  /// 持久化保存 token。
  Future<void> setToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(GlobalConstants.TOKEN_KEY, token);
  }

  /// 读取本地缓存的 token。
  ///
  /// 如果本地没有 token，则返回空字符串。
  Future<String> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(GlobalConstants.TOKEN_KEY) ?? '';
  }

  /// 删除本地缓存的 token。
  ///
  /// 一般在退出登录或 token 失效时调用。
  Future<void> deleteToken() async {
    final prefs = await _prefs;
    await prefs.remove(GlobalConstants.TOKEN_KEY);
  }
}

/// TokenManager 的全局单例入口。
final tokenManager = TokenManager();

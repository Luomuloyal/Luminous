import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// 全局运行时常量集合。
///
/// 这里存放的是“整个应用都会依赖”的基础配置，例如：
/// - 后端服务地址；
/// - 默认超时时间；
/// - 成功响应码；
/// - 本地持久化使用的 key。
class GlobalConstants {
  /// 当前后端服务根地址。
  ///
  /// 可通过 `--dart-define=API_BASE_URL=...` 强制覆盖；
  /// 若未覆盖，默认按平台选择本地联调地址。
  static String get BASE_URL {
    const String override = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: '',
    );
    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      return 'https://devluo.com';
    }

    return defaultTargetPlatform == TargetPlatform.android
        ? 'https://devluo.com'
        : 'https://devluo.com';
  }

  /// 网络请求默认超时时间，单位是秒。
  ///
  /// `DioRequest` 会同时把它用于连接、发送和接收超时。
  static const int TIME_OUT = 15;

  /// AI 安全分析接口接收超时时间（单位：秒）。
  ///
  /// 该接口可能触发大模型推理，耗时通常高于普通 CRUD 接口。
  static const int AI_SAFETY_RECEIVE_TIMEOUT = 90;

  /// AI 视觉识别接口接收超时时间（单位：秒）。
  ///
  /// 图像识别通常包含上传和推理，耗时高于文本接口。
  static const int AI_SCAN_RECEIVE_TIMEOUT = 120;

  /// 后端约定的“请求成功”业务码。
  ///
  /// 当前项目约定 `code == "1"` 时表示业务成功。
  static const String SUCCESS_CODE = '1';

  /// 本地存储 AT 时使用的 key。
  static const String TOKEN_KEY = 'luminous_access_token';

  /// 本地存储 RT 时使用的 key。
  static const String REFRESH_TOKEN_KEY = 'luminous_refresh_token';

  /// 本地存储用户信息时使用的 key。
  ///
  /// `UserController` 会使用这个 key 持久化登录用户信息。
  static const String USER_KEY = 'luminous_user';

  /// 本地存储主题模式偏好时使用的 key。
  static const String THEME_MODE_KEY = 'luminous_theme_mode';

  /// 本地存储主题风格偏好时使用的 key。
  static const String THEME_STYLE_KEY = 'luminous_theme_style';

  /// 本地存储语言偏好时使用的 key。
  static const String LOCALE_KEY = 'luminous_locale';

  /// 本地存储氛围装饰透明度偏好时使用的 key。
  static const String ORNAMENT_TRANSPARENCY_KEY =
      'luminous_ornament_transparency';
}

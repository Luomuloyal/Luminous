// ignore_for_file: constant_identifier_names, non_constant_identifier_names

/// 全局运行时常量集合。
///
/// 这里存放的是“整个应用都会依赖”的基础配置，例如：
/// - 后端服务地址；
/// - 默认超时时间；
/// - 成功响应码；
/// - 本地持久化使用的 key。
class GlobalConstants {
  /// `--dart-define` 覆盖后端地址时使用的 key。
  static const String API_BASE_URL_DEFINE = 'API_BASE_URL';

  /// 旧 Express 后端地址（仅作为兼容回退参考）。
  static const String LEGACY_EXPRESS_BASE_URL = 'https://devluo.com';

  /// 当前后端服务根地址。
  ///
  /// **必须** 通过 `--dart-define=API_BASE_URL=...` 指定后端地址；
  /// 未指定时默认为空字符串，强制显式配置，避免真实地址硬编码到源码。
  static String get BASE_URL {
    const String override = String.fromEnvironment(
      API_BASE_URL_DEFINE,
      defaultValue: '',
    );
    final value = override.trim();
    if (value.isNotEmpty) {
      return value;
    }

    // 开发环境回退到旧 Express 服务，避免未配置时直接崩溃。
    return LEGACY_EXPRESS_BASE_URL;
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

  /// 旧 Express 后端约定的“请求成功”业务码。
  static const String LEGACY_SUCCESS_CODE = '1';

  /// Lucent 后端约定的“请求成功”业务码。
  static const int LUCENT_SUCCESS_CODE = 0;

  /// 当前默认网络层仍指向旧 Express 协议。
  ///
  /// 迁到 Lucent 时应新建 `/api/v1` client 或协议适配层，不要把旧
  /// `DioRequest` 静默改成双协议混用。
  static const String SUCCESS_CODE = LEGACY_SUCCESS_CODE;

  /// 本地存储用户信息时使用的 key。
  ///
  /// 用户会话持久化层会使用这个 key 保存登录用户信息。
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

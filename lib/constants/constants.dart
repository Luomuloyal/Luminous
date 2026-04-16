import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';

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

/// 后端接口路径常量集合。
///
/// API 层统一引用这里的路径，避免在业务代码里散落硬编码接口字符串。
class HttpConstants {
  /// 获取验证码接口。
  static const String SEND_CODE = '/api/auth/codes';

  /// 用户注册接口。
  static const String REGISTER_USER = '/api/auth/register';

  /// 用户登录接口。
  static const String LOGIN_USER = '/api/auth/login';

  /// 刷新鉴权 Token 接口。
  static const String REFRESH_TOKEN = '/api/auth/refresh';

  /// 个人资料读取接口。
  static const String USER_PROFILE = '/api/user/profile';

  /// 个人资料更新接口。
  static const String USER_PROFILE_UPDATE = '/api/user/profile-update';

  /// 注销账户接口。
  static const String USER_DELETE = '/api/user/delete';

  /// 我的药品新增/更新接口。
  static const String MY_MEDICINE_UPSERT = '/api/medicines/my-upsert';

  /// 我的药品删除接口。
  static const String MY_MEDICINE_DELETE = '/api/medicines/my-delete';

  /// 我的药品列表接口。
  static const String MY_MEDICINE_LIST = '/api/medicines/my-list';

  /// 首页今日提醒接口。
  static const String TODAY_REMINDERS = '/api/reminders/today';

  /// 药品搜索接口。
  static const String MEDICINE_SEARCH = '/api/medicines/search';

  /// 药品详情接口。
  static const String MEDICINE_DETAIL = '/api/medicines/detail';

  /// 药品 AI 详情解读接口。
  static const String MEDICINE_AI_DETAIL = '/api/medicines/ai-detail';

  /// 药品识别接口。
  static const String MEDICINE_SCAN = '/api/medicines/scan';

  /// 识别记录创建接口。
  static const String SCAN_RECORD_CREATE = '/api/medicines/scan-record-create';

  /// 提醒计划新增/更新接口。
  static const String REMINDER_UPSERT = '/api/reminders/upsert';

  /// 提醒计划删除接口。
  static const String REMINDER_DELETE = '/api/reminders/delete';

  /// 提醒计划列表接口。
  static const String REMINDER_LIST = '/api/reminders/list';

  /// 安全辅助 AI 查询接口。
  static const String MEDICINE_AI_SAFETY = '/api/medicines/ai-safety';
}

/// 应用内统一使用的 UI 色值。
class AppUiConstants {
  AppUiConstants._();

  /// 四个主 Tab 页面共享的背景底色。
  static const Color PAGE_BACKGROUND = Color(0xFFF8FAFD);

  /// 底部 Tab 栏背景色，比页面底色略深一点。
  static const Color TAB_BAR_BACKGROUND = Color(0xFFFBFCFF);

  /// 底部 Tab 栏顶部描边。
  static const Color TAB_BAR_BORDER = Color(0xFFE4EAF3);

  /// 底部 Tab 未选中图标和文字颜色。
  static const Color TAB_INACTIVE = Color(0xFF7A8798);

  /// 四个 Tab 选中时的主题色。
  static const List<Color> TAB_ACTIVE_COLORS = <Color>[
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFE77AA6),
  ];
}

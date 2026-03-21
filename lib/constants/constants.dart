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
  /// 所有接口最终都会以这个地址作为前缀进行请求。
  static const String BASE_URL = 'https://wty10hv6az.sealosbja.site';

  /// 网络请求默认超时时间，单位是秒。
  ///
  /// `DioRequest` 会同时把它用于连接、发送和接收超时。
  static const int TIME_OUT = 15;

  /// 后端约定的“请求成功”业务码。
  ///
  /// 当前项目约定 `code == "1"` 时表示业务成功。
  static const String SUCCESS_CODE = '1';

  /// 本地存储 token 时使用的 key。
  ///
  /// 当前项目还没有完整接入 token 鉴权，但 key 已预留。
  static const String TOKEN_KEY = 'luminous_token';

  /// 本地存储用户信息时使用的 key。
  ///
  /// `UserController` 会使用这个 key 持久化登录用户信息。
  static const String USER_KEY = 'luminous_user';
}

/// 后端接口路径常量集合。
///
/// API 层统一引用这里的路径，避免在业务代码里散落硬编码接口字符串。
class HttpConstants {
  /// 获取验证码接口。
  static const String SEND_CODE = '/send-code';

  /// 用户注册接口。
  static const String REGISTER_USER = '/register-user';

  /// 用户登录接口。
  static const String LOGIN_USER = '/login-user';

  /// 我的药品新增/更新接口。
  static const String MY_MEDICINE_UPSERT = '/my-medicine-upsert';

  /// 我的药品删除接口。
  static const String MY_MEDICINE_DELETE = '/my-medicine-delete';

  /// 我的药品列表接口。
  static const String MY_MEDICINE_LIST = '/my-medicine-list';

  /// 首页今日提醒接口。
  static const String TODAY_REMINDERS = '/today-reminders';

  /// 药品搜索接口。
  static const String MEDICINE_SEARCH = '/medicine-search';

  /// 药品详情接口。
  static const String MEDICINE_DETAIL = '/medicine-detail';

  /// 药品 AI 详情解读接口。
  static const String MEDICINE_AI_DETAIL = '/medicine-ai-detail';

  /// 药品识别接口。
  static const String MEDICINE_SCAN = '/medicine-scan';

  /// 识别记录创建接口。
  static const String SCAN_RECORD_CREATE = '/scan-record-create';

  /// 识别记录列表接口。
  static const String SCAN_RECORD_LIST = '/scan-record-list';

  /// 提醒计划新增/更新接口。
  static const String REMINDER_UPSERT = '/reminder-upsert';

  /// 提醒计划删除接口。
  static const String REMINDER_DELETE = '/reminder-delete';

  /// 提醒计划列表接口。
  static const String REMINDER_LIST = '/reminder-list';

  /// 用药打卡创建接口。
  static const String CHECKIN_CREATE = '/checkin-create';

  /// 安全辅助 AI 查询接口。
  static const String MEDICINE_AI_SAFETY = '/medicine-ai-safety';
}

/// 应用内统一使用的 UI 色值。
class AppUiConstants {
  AppUiConstants._();

  /// 四个主 Tab 页面共享的背景底色。
  static const Color PAGE_BACKGROUND = Color(0xFFF3F7FB);

  /// 底部 Tab 栏背景色，比页面底色略深一点。
  static const Color TAB_BAR_BACKGROUND = Color(0xFFF8FAFD);

  /// 底部 Tab 栏顶部描边。
  static const Color TAB_BAR_BORDER = Color(0xFFDCE6F2);

  /// 底部 Tab 未选中图标和文字颜色。
  static const Color TAB_INACTIVE = Color(0xFF7B8798);

  /// 四个 Tab 选中时的主题色。
  static const List<Color> TAB_ACTIVE_COLORS = <Color>[
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF14B8A6),
  ];
}

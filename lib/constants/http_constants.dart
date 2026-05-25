// ignore_for_file: constant_identifier_names

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

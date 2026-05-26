/// 应用路由路径常量。
///
/// 从 `app_router.dart` 中提取路径字符串，避免路由路径散落在各处。
class AppRoutes {
  AppRoutes._();

  /// 主页（底部 Tab 壳层）。
  static const String home = '/';

  /// 登录页。
  static const String login = '/login';

  /// 注册页。
  static const String register = '/register';

  /// 搜索页。
  static const String search = '/search';

  /// 扫码页。
  static const String scan = '/scan';

  /// 提醒列表页。
  static const String reminders = '/reminders';

  /// 打卡页。
  static const String checkin = '/checkin';

  /// 安全辅助页。
  static const String safety = '/safety';

  /// 设置页。
  static const String settings = '/settings';

  /// 个人资料设置页。
  static const String profileSettings = '/profile-settings';
}

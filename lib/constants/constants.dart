// ignore_for_file: constant_identifier_names, non_constant_identifier_names
class GlobalConstants {
  // 项目全局常量集中管理，避免魔法字符串/魔法数字散落各处。
  // 注意：BASE_URL 变更时只改这里即可（例如你重新部署后端到新域名）。
  static const String BASE_URL = 'https://wty10hv6az.sealosbja.site';
  static const int TIME_OUT = 15;
  static const String SUCCESS_CODE = '1';
  static const String TOKEN_KEY = 'luminous_token';
  static const String USER_KEY = 'luminous_user';
}

class HttpConstants {
  // 接口路径常量：统一维护，API 层引用这些常量，避免手写字符串出错。
  static const String SEND_CODE = '/send-code';
  static const String REGISTER_USER = '/register-user';
  static const String LOGIN_USER = '/login-user';

  static const String TODAY_REMINDERS = '/today-reminders';

  static const String MEDICINE_SEARCH = '/medicine-search';
  static const String MEDICINE_DETAIL = '/medicine-detail';
  static const String MEDICINE_AI_DETAIL = '/medicine-ai-detail';
}

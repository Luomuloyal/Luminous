/// Lucent `/api/v1` 端点常量。
///
/// 新 Lucent client 统一引用这里的路径，不散落在业务代码中。
/// 随着后端接口逐步实现，在此追加对应的端点常量。
class LucentEndpoints {
  LucentEndpoints._();

  /// API 版本前缀。
  static const String v1 = '/api/v1';

  /// 健康检查。
  static const String health = '/api/v1/health';
}

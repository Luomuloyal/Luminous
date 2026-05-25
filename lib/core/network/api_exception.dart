/// 统一的接口异常类型。
///
/// 页面层只需要 catch 这一种异常，然后把消息展示给用户即可。
/// legacy Express client 与 Lucent client 共用此类。
class ApiException implements Exception {
  /// 具体错误消息。
  final String message;

  /// 业务错误码。
  final String? code;

  /// 创建一个接口异常对象。
  const ApiException(this.message, {this.code});

  /// 返回可读的错误字符串。
  @override
  String toString() => message;

  /// 错误码是否等于给定值。
  bool hasCode(String other) => code == other;
}

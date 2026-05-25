import 'package:luminous/constants/constants.dart';

/// 网络超时配置。
///
/// 供 legacy Express client 与 Lucent client 共同引用，
/// 避免各自散落魔数。
class NetworkTimeoutConfig {
  NetworkTimeoutConfig._();

  /// 默认请求超时（连接 / 发送 / 接收）。
  static Duration get defaultTimeout =>
      Duration(seconds: GlobalConstants.TIME_OUT);

  /// AI 安全分析接口接收超时。
  static Duration get aiSafetyReceiveTimeout =>
      Duration(seconds: GlobalConstants.AI_SAFETY_RECEIVE_TIMEOUT);

  /// AI 视觉识别接口接收超时。
  static Duration get aiScanReceiveTimeout =>
      Duration(seconds: GlobalConstants.AI_SCAN_RECEIVE_TIMEOUT);
}

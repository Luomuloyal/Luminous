/// 发版相关的统一展示信息。
class AppReleaseInfo {
  AppReleaseInfo._();

  /// 正式版软件名。
  static const String appName = 'Luminous';

  /// 主版本号。
  static const String versionName = '3.3.0';

  /// 构建号。
  static const String buildNumber = '77';

  /// 应用内展示的完整版本号。
  static const String fullVersion = '$versionName+$buildNumber';
}

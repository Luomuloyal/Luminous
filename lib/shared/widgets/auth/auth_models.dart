part of 'auth.dart';

/// 认证方式切换器选项对象。
class AuthMethodItem {
  /// 创建一个方法切换器选项对象。
  const AuthMethodItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  /// 选项显示文本（例如“密码登录”“验证码登录”）。
  final String label;

  /// 当前选项是否处于选中状态。
  final bool selected;

  /// 点击该选项时的回调。
  final VoidCallback onTap;
}

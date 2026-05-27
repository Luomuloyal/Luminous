import 'package:flutter/widgets.dart';

/// 全局阴影 token。
///
/// 提供语义化 BoxShadow 预设，组件不直接写 `blurRadius: 14`。
class AppShadow {
  AppShadow._();

  // -- 卡片 / 浮层级 --

  /// 浅阴影：卡片悬浮、auth form、soft banner。
  static BoxShadow get card =>
      const BoxShadow(color: Color(0x120F172A), blurRadius: 14, offset: Offset(0, 7));

  /// 深阴影：app surface card 暗色模式、toast。
  static BoxShadow get surface =>
      const BoxShadow(color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10));

  /// light 模式 surface card 次阴影。
  static BoxShadow get surfaceLight =>
      const BoxShadow(color: Color(0x0F0F172A), blurRadius: 16, offset: Offset(0, 7));

  // -- 底部导航 / 悬浮按钮 --

  /// 底部 Tab 栏主阴影。
  static BoxShadow bottomBar(Color color) =>
      BoxShadow(color: color, blurRadius: 22, offset: const Offset(0, 10));

  /// 底部 Tab 栏装饰节点阴影。
  static BoxShadow bottomBarOrnament(Color color) =>
      BoxShadow(color: color, blurRadius: 16, offset: const Offset(0, 6));

  // -- 认证页 --

  /// 登录/注册切换卡阴影。
  static BoxShadow get authCard =>
      const BoxShadow(color: Color(0x100F172A), blurRadius: 12, offset: Offset(0, 6));

  /// 登录/注册选中卡片阴影。
  static BoxShadow authCardSelected(Color color) =>
      BoxShadow(color: color, blurRadius: 14, offset: const Offset(0, 6));
}

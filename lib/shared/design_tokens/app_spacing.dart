import 'package:flutter/widgets.dart';

/// 全局间距 token。
///
/// 页面和组件引用此处的语义化 EdgeInsets / SizedBox 预设，
/// 避免散落 `EdgeInsets.fromLTRB(16, 0, 16, 24)` 等魔数。
class AppSpacing {
  AppSpacing._();

  // -- 基础步进 --

  static const double xs = 4;
  static const double sm = 6;
  static const double md = 8;
  static const double lg = 10;
  static const double xl = 12;
  static const double xxl = 14;
  static const double huge = 16;
  static const double massive = 20;
  static const double giant = 24;

  // -- 常用 EdgeInsets --

  /// 页面级水平边距：H=16, V=0。
  static const EdgeInsets hPage = EdgeInsets.symmetric(horizontal: huge);

  /// 页面级全向边距：16。
  static const EdgeInsets allPage = EdgeInsets.all(huge);

  /// 卡片级全向边距：12。
  static const EdgeInsets allCard = EdgeInsets.all(xl);

  /// 卡片内边距：L=12, T=10, R=12, B=12。
  static const EdgeInsets cardContent =
      EdgeInsets.fromLTRB(xl, lg, xl, xl);

  /// 输入框内容边距：H=14, V=14。
  static const EdgeInsets inputContent =
      EdgeInsets.symmetric(horizontal: xxl, vertical: xxl);

  /// 紧凑型 chip 边距：H=10, V=6。
  static const EdgeInsets chipCompact =
      EdgeInsets.symmetric(horizontal: lg, vertical: sm);

  /// 小 chip 边距：H=10, V=7。
  static const EdgeInsets chipSmall =
      EdgeInsets.fromLTRB(lg, sm + 1, lg, sm + 1);

  // -- 常用 SizedBox --

  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapHuge = SizedBox(height: huge);
}

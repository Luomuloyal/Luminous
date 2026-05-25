import 'package:flutter/material.dart';

// ignore_for_file: constant_identifier_names

/// 应用内统一使用的 UI 色值。
class AppUiConstants {
  AppUiConstants._();

  /// 四个主 Tab 页面共享的背景底色。
  static const Color PAGE_BACKGROUND = Color(0xFFF8FAFD);

  /// 底部 Tab 栏背景色，比页面底色略深一点。
  static const Color TAB_BAR_BACKGROUND = Color(0xFFFBFCFF);

  /// 底部 Tab 栏顶部描边。
  static const Color TAB_BAR_BORDER = Color(0xFFE4EAF3);

  /// 底部 Tab 未选中图标和文字颜色。
  static const Color TAB_INACTIVE = Color(0xFF7A8798);

  /// 四个 Tab 选中时的主题色。
  static const List<Color> TAB_ACTIVE_COLORS = <Color>[
    Color(0xFF0EA5E9),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFE77AA6),
  ];
}

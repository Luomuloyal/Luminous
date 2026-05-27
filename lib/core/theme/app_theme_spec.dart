import 'package:flutter/material.dart';
import 'package:luminous/core/providers/theme_provider.dart';

/// 主题色板规格。
///
/// 每种主题风格定义一组亮色/暗色的主色、辅色、背景色和表面色。
/// 从 `root_app_widget.dart` 迁出，供 `_buildLightTheme` / `_buildDarkTheme`
/// 及其他主题相关代码引用。
class AppThemeSpec {
  const AppThemeSpec({
    required this.lightPrimary,
    required this.lightSecondary,
    required this.lightTertiary,
    required this.lightBackground,
    required this.darkPrimary,
    required this.darkSecondary,
    required this.darkTertiary,
    required this.darkBackground,
    required this.darkSurface,
    required this.darkSurfaceAlt,
  });

  final Color lightPrimary;
  final Color lightSecondary;
  final Color lightTertiary;
  final Color lightBackground;
  final Color darkPrimary;
  final Color darkSecondary;
  final Color darkTertiary;
  final Color darkBackground;
  final Color darkSurface;
  final Color darkSurfaceAlt;
}

/// 根据主题风格返回对应的色板规格。
AppThemeSpec themeSpecFor(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return const AppThemeSpec(
        lightPrimary: Color(0xFF3FA9E8),
        lightSecondary: Color(0xFFCAA4E8),
        lightTertiary: Color(0xFFF1CB8A),
        lightBackground: Color(0xFFF7FBFF),
        darkPrimary: Color(0xFFA6DBFF),
        darkSecondary: Color(0xFFD8C1FF),
        darkTertiary: Color(0xFFE9D08E),
        darkBackground: Color(0xFF0B1524),
        darkSurface: Color(0xFF14243A),
        darkSurfaceAlt: Color(0xFF1E3351),
      );
    case AppThemeStyle.moonMist:
      return const AppThemeSpec(
        lightPrimary: Color(0xFF5A8FE6),
        lightSecondary: Color(0xFF9AA5F2),
        lightTertiary: Color(0xFFC5D3FF),
        lightBackground: Color(0xFFF3F7FD),
        darkPrimary: Color(0xFFAACBFF),
        darkSecondary: Color(0xFFC3C8FF),
        darkTertiary: Color(0xFF8FAEED),
        darkBackground: Color(0xFF081523),
        darkSurface: Color(0xFF122435),
        darkSurfaceAlt: Color(0xFF1A314A),
      );
    case AppThemeStyle.divineTree:
      return const AppThemeSpec(
        lightPrimary: Color(0xFF8FA85C),
        lightSecondary: Color(0xFFD8BD71),
        lightTertiary: Color(0xFFAFCC92),
        lightBackground: Color(0xFFFBFAF0),
        darkPrimary: Color(0xFFD1E4A0),
        darkSecondary: Color(0xFFE1CB85),
        darkTertiary: Color(0xFF9BC68A),
        darkBackground: Color(0xFF0B120C),
        darkSurface: Color(0xFF15231A),
        darkSurfaceAlt: Color(0xFF203327),
      );
    case AppThemeStyle.illusion:
      return const AppThemeSpec(
        lightPrimary: Color(0xFF9272E6),
        lightSecondary: Color(0xFFB89BEF),
        lightTertiary: Color(0xFF88A0E8),
        lightBackground: Color(0xFFF7F4FF),
        darkPrimary: Color(0xFFD0C0FF),
        darkSecondary: Color(0xFFA99AEF),
        darkTertiary: Color(0xFF87A0E4),
        darkBackground: Color(0xFF110B1E),
        darkSurface: Color(0xFF1F1730),
        darkSurfaceAlt: Color(0xFF2B1F45),
      );
    case AppThemeStyle.lightSand:
      return const AppThemeSpec(
        lightPrimary: Color(0xFFBD9C7D),
        lightSecondary: Color(0xFFD6B1A6),
        lightTertiary: Color(0xFFC89072),
        lightBackground: Color(0xFFFAF1E9),
        darkPrimary: Color(0xFFE0C6AF),
        darkSecondary: Color(0xFFD8B1A7),
        darkTertiary: Color(0xFFC89074),
        darkBackground: Color(0xFF17110D),
        darkSurface: Color(0xFF241B15),
        darkSurfaceAlt: Color(0xFF32251E),
      );
  }
}

/// 兜底色板规格（当未知主题风格时使用，等同 softGlow）。
const AppThemeSpec fallbackThemeSpec = AppThemeSpec(
  lightPrimary: Color(0xFF3FA9E8),
  lightSecondary: Color(0xFFCAA4E8),
  lightTertiary: Color(0xFFF1CB8A),
  lightBackground: Color(0xFFF7FBFF),
  darkPrimary: Color(0xFFA6DBFF),
  darkSecondary: Color(0xFFD8C1FF),
  darkTertiary: Color(0xFFE9D08E),
  darkBackground: Color(0xFF0B1524),
  darkSurface: Color(0xFF14243A),
  darkSurfaceAlt: Color(0xFF1E3351),
);

/// 安全获取主题色板，异常时返回 [fallbackThemeSpec]。
AppThemeSpec safeThemeSpec(AppThemeStyle style) {
  try {
    return themeSpecFor(style);
  } catch (_) {
    return fallbackThemeSpec;
  }
}

// ---- 颜色辅助函数 ----

Color softenedLightBackground(Color themedBackground) {
  return Color.lerp(const Color(0xFFF7F9FC), themedBackground, 0.72)!;
}

Color softenedDarkBackground(Color themedBackground) {
  return Color.lerp(const Color(0xFF0C1118), themedBackground, 0.72)!;
}

Color lightOnSurfaceVariant(AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(spec.lightPrimary, spec.lightSecondary, 0.42)!
        .withValues(alpha: 0.10),
    const Color(0xFF65758A),
  );
}

Color lightOutline(AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(spec.lightPrimary, spec.lightSecondary, 0.48)!
        .withValues(alpha: 0.16),
    const Color(0xFFD9E2ED),
  );
}

Color lightDivider(AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(spec.lightSecondary, spec.lightTertiary, 0.42)!
        .withValues(alpha: 0.12),
    const Color(0xFFE2E8F0),
  );
}

Color lightCardBorder(AppThemeSpec spec) {
  return Color.alphaBlend(
    Color.lerp(spec.lightPrimary, spec.lightTertiary, 0.34)!
        .withValues(alpha: 0.12),
    const Color(0xFFE4EAF2),
  );
}

part of 'soft_banner.dart';

/// 顶部浅色渐变横幅配色基底。
class SoftBannerPalette {
  /// 创建一个横幅配色基底。
  const SoftBannerPalette({
    required this.startColor,
    required this.endColor,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.surfaceColor,
    required this.surfaceTextColor,
    required this.borderColor,
    required this.shadowColor,
  });

  /// 主渐变起始色。
  final Color startColor;

  /// 主渐变结束色。
  final Color endColor;

  /// 横幅装饰色。
  final Color accentColor;

  /// 主文字颜色。
  final Color textColor;

  /// 次文字颜色。
  final Color secondaryTextColor;

  /// 轻按钮/胶囊背景色。
  final Color surfaceColor;

  /// 轻按钮/胶囊文字色。
  final Color surfaceTextColor;

  /// 描边颜色。
  final Color borderColor;

  /// 阴影颜色。
  final Color shadowColor;

  /// 根据配色基底生成横幅主题。
  SoftBannerTheme createTheme() {
    return SoftBannerTheme._(
      startColor: startColor,
      endColor: endColor,
      accentColor: accentColor,
      textColor: textColor,
      secondaryTextColor: secondaryTextColor,
      surfaceColor: surfaceColor,
      surfaceTextColor: surfaceTextColor,
      borderColor: borderColor,
      shadowColor: shadowColor,
    );
  }
}

/// 顶部浅色渐变横幅主题。
class SoftBannerTheme {
  const SoftBannerTheme._({
    required this.startColor,
    required this.endColor,
    required this.accentColor,
    required this.textColor,
    required this.secondaryTextColor,
    required this.surfaceColor,
    required this.surfaceTextColor,
    required this.borderColor,
    required this.shadowColor,
  });

  final Color startColor;
  final Color endColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color surfaceColor;
  final Color surfaceTextColor;
  final Color borderColor;
  final Color shadowColor;
}

/// 预设的横幅配色基底集合。
class SoftBannerPalettes {
  SoftBannerPalettes._();

  /// 兼容测试与静态预览场景使用的默认配色。
  static const SoftBannerPalette home = SoftBannerPalette(
    startColor: Color(0xFFEAF6FF),
    endColor: Color(0xFFF3F1FF),
    accentColor: Color(0xFF7CC4F8),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFF0F4C81),
    borderColor: Color(0xFFD9ECFF),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette drug = SoftBannerPalette(
    startColor: Color(0xFFFFF7F0),
    endColor: Color(0xFFFFFBF6),
    accentColor: Color(0xFFE3B37A),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFF9B6B35),
    borderColor: Color(0xFFF4E4CF),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette album = SoftBannerPalette(
    startColor: Color(0xFFFFFBF1),
    endColor: Color(0xFFF7FAFF),
    accentColor: Color(0xFFE4C977),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFF9A8742),
    borderColor: Color(0xFFF2E6BE),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette mine = SoftBannerPalette(
    startColor: Color(0xFFF8F4FF),
    endColor: Color(0xFFFFF6FB),
    accentColor: Color(0xFFD0AFE8),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFF8B66A4),
    borderColor: Color(0xFFEEE2F9),
    shadowColor: Color(0x140F172A),
  );

  static const SoftBannerPalette auth = SoftBannerPalette(
    startColor: Color(0xFFEAF6FF),
    endColor: Color(0xFFF0F6FF),
    accentColor: Color(0xFF7CC4F8),
    textColor: Color(0xFF0F172A),
    secondaryTextColor: Color(0xFF475569),
    surfaceColor: Color(0xD9FFFFFF),
    surfaceTextColor: Color(0xFF0F4C81),
    borderColor: Color(0xFFD9ECFF),
    shadowColor: Color(0x140F172A),
  );

  static SoftBannerPalette homeOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _build(
      context,
      accent: scheme.primary,
      secondary: scheme.secondary,
      tertiary: scheme.tertiary,
    );
  }

  static SoftBannerPalette drugOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _build(
      context,
      accent: scheme.primary,
      secondary: Color.lerp(scheme.primary, scheme.secondary, 0.5)!,
      tertiary: scheme.tertiary,
    );
  }

  static SoftBannerPalette albumOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _build(
      context,
      accent: scheme.tertiary,
      secondary: scheme.primary,
      tertiary: scheme.secondary,
    );
  }

  static SoftBannerPalette mineOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _build(
      context,
      accent: scheme.secondary,
      secondary: scheme.tertiary,
      tertiary: scheme.primary,
    );
  }

  static SoftBannerPalette authOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _build(
      context,
      accent: Color.lerp(scheme.primary, scheme.secondary, 0.28)!,
      secondary: Color.lerp(scheme.secondary, scheme.tertiary, 0.42)!,
      tertiary: Color.lerp(scheme.primary, scheme.tertiary, 0.34)!,
    );
  }

  static SoftBannerPalette _build(
    BuildContext context, {
    required Color accent,
    required Color secondary,
    Color? tertiary,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? scheme.surface : theme.scaffoldBackgroundColor;
    final endAccent = tertiary ?? secondary;
    final accentTone = isDark
        ? Color.lerp(accent, Colors.white, 0.16)!
        : accent;
    final borderBase = isDark
        ? Color.alphaBlend(accent.withValues(alpha: 0.20), scheme.outline)
        : Color.alphaBlend(secondary.withValues(alpha: 0.12), scheme.outline);

    return SoftBannerPalette(
      startColor: Color.alphaBlend(
        accent.withValues(alpha: isDark ? 0.18 : 0.10),
        baseColor,
      ),
      endColor: Color.alphaBlend(
        endAccent.withValues(alpha: isDark ? 0.14 : 0.075),
        baseColor,
      ),
      accentColor: accentTone,
      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
      secondaryTextColor: isDark
          ? const Color(0xFFCBD5E1)
          : const Color(0xFF475569),
      surfaceColor: isDark
          ? Color.alphaBlend(
              Colors.white.withValues(alpha: 0.09),
              scheme.surface,
            )
          : Colors.white.withValues(alpha: 0.82),
      surfaceTextColor: accentTone,
      borderColor: borderBase,
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.24)
          : const Color(0x140F172A),
    );
  }
}

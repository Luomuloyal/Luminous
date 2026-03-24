import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';

/// 顶部浅色渐变横幅配色基底。
class SoftBannerPalette {
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
  final Color startColor;
  final Color endColor;
  final Color accentColor;
  final Color textColor;
  final Color secondaryTextColor;
  final Color surfaceColor;
  final Color surfaceTextColor;
  final Color borderColor;
  final Color shadowColor;

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
      accent: scheme.primary,
      secondary: scheme.secondary,
      tertiary: scheme.tertiary,
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
      borderColor: Color.alphaBlend(
        (isDark ? accent : secondary).withValues(alpha: isDark ? 0.24 : 0.10),
        scheme.outline,
      ),
      shadowColor: isDark
          ? Colors.black.withValues(alpha: 0.24)
          : const Color(0x140F172A),
    );
  }
}

/// 浅色渐变横幅容器。
class SoftBannerCard extends StatelessWidget {
  const SoftBannerCard({
    super.key,
    required this.palette,
    required this.builder,
    this.ornamentStyle,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final SoftBannerPalette palette;

  /// 允许调用方根据 theme 调整前景色（标题、chip、按钮等）。
  final Widget Function(BuildContext context, SoftBannerTheme theme) builder;

  final AppOrnamentStyle? ornamentStyle;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = palette.createTheme();
    final resolvedStyle =
        ornamentStyle ??
        _resolveBannerOrnamentStyle(
          palette.startColor,
          palette.endColor,
          palette.accentColor,
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: theme.borderColor),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.startColor, theme.endColor],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            ..._buildBannerOrnaments(style: resolvedStyle, theme: theme),
            Padding(
              padding: padding,
              child: SizedBox(
                width: double.infinity,
                child: builder(context, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppOrnamentStyle _resolveBannerOrnamentStyle(
  Color startColor,
  Color endColor,
  Color accentColor,
) {
  final seed =
      startColor.toARGB32() ^ endColor.toARGB32() ^ accentColor.toARGB32();
  final index = seed.abs() % AppOrnamentStyle.values.length;
  return AppOrnamentStyle.values[index];
}

List<Widget> _buildBannerOrnaments({
  required AppOrnamentStyle style,
  required SoftBannerTheme theme,
}) {
  final strong = theme.accentColor.withValues(alpha: 0.16);
  final medium = theme.accentColor.withValues(alpha: 0.12);
  final light = theme.accentColor.withValues(alpha: 0.085);

  switch (style) {
    case AppOrnamentStyle.orbit:
      return [
        Positioned(
          top: -44,
          right: -42,
          child: _SoftBannerBlob(width: 118, height: 118, color: strong),
        ),
        Positioned(
          top: 30,
          right: 72,
          child: _SoftBannerBlob(
            width: 24,
            height: 24,
            color: theme.accentColor.withValues(alpha: 0.26),
          ),
        ),
        Positioned(
          bottom: -70,
          left: -66,
          child: _SoftBannerBlob(width: 132, height: 132, color: light),
        ),
      ];
    case AppOrnamentStyle.comet:
      return [
        Positioned(
          top: -26,
          right: -44,
          child: Transform.rotate(
            angle: -0.32,
            child: _SoftBannerPill(width: 152, height: 88, color: strong),
          ),
        ),
        Positioned(
          top: 18,
          right: 30,
          child: _SoftBannerBlob(
            width: 18,
            height: 18,
            color: theme.accentColor.withValues(alpha: 0.24),
          ),
        ),
        Positioned(
          bottom: -72,
          left: -58,
          child: Transform.rotate(
            angle: 0.38,
            child: _SoftBannerPill(width: 154, height: 94, color: light),
          ),
        ),
      ];
    case AppOrnamentStyle.petal:
      return [
        Positioned(
          top: -38,
          right: -14,
          child: _SoftBannerBlob(width: 102, height: 102, color: strong),
        ),
        Positioned(
          top: -10,
          right: 50,
          child: _SoftBannerBlob(width: 58, height: 58, color: medium),
        ),
        Positioned(
          top: 42,
          right: 30,
          child: _SoftBannerBlob(
            width: 16,
            height: 16,
            color: theme.accentColor.withValues(alpha: 0.28),
          ),
        ),
        Positioned(
          bottom: -68,
          left: -60,
          child: _SoftBannerBlob(width: 138, height: 138, color: light),
        ),
      ];
    case AppOrnamentStyle.halo:
      return [
        Positioned(
          top: -42,
          right: -8,
          child: _SoftBannerRing(
            size: 116,
            color: medium,
            borderColor: theme.accentColor.withValues(alpha: 0.22),
          ),
        ),
        Positioned(
          top: 18,
          right: 54,
          child: _SoftBannerBlob(width: 34, height: 34, color: strong),
        ),
        Positioned(
          top: 64,
          right: 26,
          child: _SoftBannerBlob(
            width: 14,
            height: 14,
            color: theme.accentColor.withValues(alpha: 0.28),
          ),
        ),
        Positioned(
          bottom: -70,
          left: -66,
          child: _SoftBannerBlob(width: 136, height: 136, color: light),
        ),
      ];
  }
}

class _SoftBannerBlob extends StatelessWidget {
  const _SoftBannerBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SoftBannerPill extends StatelessWidget {
  const _SoftBannerPill({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SoftBannerRing extends StatelessWidget {
  const _SoftBannerRing({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: borderColor, width: 1.4),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// 大分区卡片与横幅使用的轻量装饰样式。
enum AppOrnamentStyle { orbit, comet, petal, halo }

Color appTintedSurface(
  BuildContext context,
  Color accent, {
  double lightAlpha = 0.08,
  double darkAlpha = 0.14,
  Color? baseColor,
}) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(
      alpha: theme.brightness == Brightness.dark ? darkAlpha : lightAlpha,
    ),
    baseColor ?? (theme.cardTheme.color ?? theme.colorScheme.surface),
  );
}

Color appTintedBorder(
  BuildContext context,
  Color accent, {
  double lightAlpha = 0.14,
  double darkAlpha = 0.22,
  Color? baseColor,
}) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(
      alpha: theme.brightness == Brightness.dark ? darkAlpha : lightAlpha,
    ),
    baseColor ?? theme.colorScheme.outline,
  );
}

/// 统一的页面表面卡片。
///
/// 让大部分普通组件都回到同一套白卡/深卡语言：
/// - 统一圆角；
/// - 统一边框；
/// - 统一柔和阴影；
/// - 把颜色重点留给图标底板、按钮和状态块。
class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding,
    this.radius = 18,
    this.color,
    this.borderColor,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background =
        color ?? (theme.cardTheme.color ?? theme.colorScheme.surface);
    final outline = borderColor ?? theme.colorScheme.outline;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: outline),
        boxShadow: !shadow || isDark
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x0C0F172A),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}

/// 统一的大分区卡片。
///
/// 适合“常用功能”“今日提醒”这类整块区域：
/// - 保留表面卡片的干净边界；
/// - 在卡片内部叠一层极浅的区域色；
/// - 只做少量静态装饰，不使用模糊，渲染负担很低。
class AppSectionCard extends StatelessWidget {
  const AppSectionCard({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryColor,
    this.ornamentStyle,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
  });

  final Widget child;
  final Color accentColor;
  final Color? secondaryColor;
  final AppOrnamentStyle? ornamentStyle;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = theme.cardTheme.color ?? theme.colorScheme.surface;
    final resolvedStyle =
        ornamentStyle ??
        _resolveOrnamentStyle(accentColor, secondaryColor, radius);
    final startColor = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.12 : 0.085),
      baseColor,
    );
    final endColor = Color.alphaBlend(
      (secondaryColor ?? accentColor).withValues(alpha: isDark ? 0.095 : 0.062),
      baseColor,
    );

    return AppSurfaceCard(
      radius: radius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [startColor, endColor],
                  ),
                ),
              ),
            ),
            ..._buildSectionOrnaments(
              style: resolvedStyle,
              isDark: isDark,
              accentColor: accentColor,
              secondaryColor: secondaryColor ?? accentColor,
            ),
            Padding(
              padding: padding,
              child: SizedBox(width: double.infinity, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

AppOrnamentStyle _resolveOrnamentStyle(
  Color accentColor,
  Color? secondaryColor,
  double radius,
) {
  final seed =
      accentColor.toARGB32() ^
      (secondaryColor?.toARGB32() ?? accentColor.toARGB32()) ^
      radius.round();
  final index = seed.abs() % AppOrnamentStyle.values.length;
  return AppOrnamentStyle.values[index];
}

List<Widget> _buildSectionOrnaments({
  required AppOrnamentStyle style,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
}) {
  final topAlpha = isDark ? 0.12 : 0.14;
  final secondAlpha = isDark ? 0.08 : 0.10;
  final bottomAlpha = isDark ? 0.075 : 0.085;

  switch (style) {
    case AppOrnamentStyle.orbit:
      return [
        Positioned(
          top: -46,
          right: -18,
          child: _SectionOrb(
            size: 142,
            color: accentColor.withValues(alpha: topAlpha),
          ),
        ),
        Positioned(
          top: 28,
          right: 78,
          child: _SectionOrb(
            size: 24,
            color: secondaryColor.withValues(alpha: secondAlpha + 0.03),
          ),
        ),
        Positioned(
          bottom: -62,
          left: -28,
          child: _SectionOrb(
            size: 156,
            color: secondaryColor.withValues(alpha: bottomAlpha),
          ),
        ),
      ];
    case AppOrnamentStyle.comet:
      return [
        Positioned(
          top: -32,
          right: -38,
          child: Transform.rotate(
            angle: -0.35,
            child: _SectionPill(
              width: 164,
              height: 92,
              color: accentColor.withValues(alpha: topAlpha - 0.015),
            ),
          ),
        ),
        Positioned(
          top: 18,
          right: 34,
          child: _SectionOrb(
            size: 18,
            color: accentColor.withValues(alpha: secondAlpha + 0.02),
          ),
        ),
        Positioned(
          bottom: -74,
          left: -30,
          child: Transform.rotate(
            angle: 0.45,
            child: _SectionPill(
              width: 174,
              height: 102,
              color: secondaryColor.withValues(alpha: bottomAlpha),
            ),
          ),
        ),
      ];
    case AppOrnamentStyle.petal:
      return [
        Positioned(
          top: -44,
          right: -8,
          child: _SectionOrb(
            size: 112,
            color: accentColor.withValues(alpha: topAlpha - 0.01),
          ),
        ),
        Positioned(
          top: -14,
          right: 54,
          child: _SectionOrb(
            size: 62,
            color: secondaryColor.withValues(alpha: secondAlpha + 0.01),
          ),
        ),
        Positioned(
          top: 42,
          right: 24,
          child: _SectionOrb(
            size: 16,
            color: accentColor.withValues(alpha: secondAlpha + 0.04),
          ),
        ),
        Positioned(
          bottom: -56,
          left: -20,
          child: _SectionOrb(
            size: 148,
            color: secondaryColor.withValues(alpha: bottomAlpha),
          ),
        ),
      ];
    case AppOrnamentStyle.halo:
      return [
        Positioned(
          top: -48,
          right: -10,
          child: _SectionRing(
            size: 128,
            color: accentColor.withValues(alpha: topAlpha + 0.01),
            borderColor: accentColor.withValues(alpha: isDark ? 0.20 : 0.18),
          ),
        ),
        Positioned(
          top: 18,
          right: 54,
          child: _SectionOrb(
            size: 36,
            color: secondaryColor.withValues(alpha: secondAlpha + 0.02),
          ),
        ),
        Positioned(
          top: 66,
          right: 24,
          child: _SectionOrb(
            size: 14,
            color: accentColor.withValues(alpha: secondAlpha + 0.05),
          ),
        ),
        Positioned(
          bottom: -68,
          left: -34,
          child: _SectionOrb(
            size: 162,
            color: secondaryColor.withValues(alpha: bottomAlpha - 0.005),
          ),
        ),
      ];
  }
}

class _SectionOrb extends StatelessWidget {
  const _SectionOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}

class _SectionPill extends StatelessWidget {
  const _SectionPill({
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

class _SectionRing extends StatelessWidget {
  const _SectionRing({
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

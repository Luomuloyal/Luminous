import 'package:flutter/material.dart';

/// 全局浅色环境背景。
///
/// 不直接给每个组件叠彩色块，而是在页面底层铺一层很淡的环境光，
/// 让页面更柔和、卡片更干净。
class AppCanvas extends StatelessWidget {
  const AppCanvas({
    super.key,
    required this.child,
    required this.accentColor,
    this.secondaryAccentColor = const Color(0xFFDCCEFF),
    this.baseColor,
  });

  final Widget child;
  final Color accentColor;
  final Color secondaryAccentColor;
  final Color? baseColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final background = baseColor ?? theme.scaffoldBackgroundColor;
    final topTint = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.06 : 0.035),
      background,
    );
    final bottomTint = Color.alphaBlend(
      secondaryAccentColor.withValues(alpha: isDark ? 0.05 : 0.028),
      background,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [topTint, background, bottomTint],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -148,
            right: -136,
            child: _CanvasOrb(
              size: 356,
              colors: [
                accentColor.withValues(alpha: isDark ? 0.08 : 0.09),
                accentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            top: 24,
            left: -132,
            child: _CanvasOrb(
              size: 324,
              colors: [
                const Color(0xFFFDE7A9).withValues(alpha: isDark ? 0.05 : 0.10),
                const Color(0xFFFDE7A9).withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            top: 260,
            left: -96,
            child: _CanvasOrb(
              size: 280,
              colors: [
                accentColor.withValues(alpha: isDark ? 0.04 : 0.05),
                accentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            bottom: -172,
            left: -136,
            child: _CanvasOrb(
              size: 404,
              colors: [
                secondaryAccentColor.withValues(alpha: isDark ? 0.07 : 0.10),
                secondaryAccentColor.withValues(alpha: 0),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            right: -96,
            child: _CanvasOrb(
              size: 248,
              colors: [
                const Color(0xFFFFF6C8).withValues(alpha: isDark ? 0.03 : 0.08),
                const Color(0xFFFFF6C8).withValues(alpha: 0),
              ],
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _CanvasOrb extends StatelessWidget {
  const _CanvasOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

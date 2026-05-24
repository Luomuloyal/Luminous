part of '../app_surface.dart';

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
    final highlight = Colors.white.withValues(alpha: isDark ? 0.035 : 0.11);
    final boxShadows = shadow
        ? (isDark
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.20),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0x0F0F172A),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ])
        : const <BoxShadow>[];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: outline),
        boxShadow: boxShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.16, 0.52],
                      colors: [
                        highlight,
                        highlight.withValues(alpha: isDark ? 0.015 : 0.046),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (padding == null)
              child
            else
              Padding(padding: padding!, child: child),
          ],
        ),
      ),
    );
  }
}

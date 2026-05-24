part of '../app_surface.dart';

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
    this.ornamentKey,
    this.ornamentStyle,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
    this.baseColor,
    this.ornamentVisibilityScale = 1,
    this.surfaceBorderColor,
  });

  final Widget child;
  final Color accentColor;
  final Color? secondaryColor;
  final String? ornamentKey;
  final AppOrnamentStyle? ornamentStyle;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? baseColor;
  final double ornamentVisibilityScale;
  final Color? surfaceBorderColor;

  @override
  Widget build(BuildContext context) {
    if (ornamentKey == null) {
      return _buildCard(context);
    }
    if (maybeOrnamentContainerOf(context) == null) {
      return _buildCard(context);
    }
    return Consumer(
      builder: (context, ref, _) {
        final ornamentState = ref.watch(ornamentProvider);
        final ornamentNotifier = ref.read(ornamentProvider.notifier);
        final resolvedVisibility =
            (ornamentState.visibilityFactor * ornamentVisibilityScale).clamp(
              0.0,
              1.0,
            );
        return _buildCard(
          context,
          ornamentVisibilityFactor: resolvedVisibility,
          sessionLayout: ornamentNotifier.resolveLayout(
            ornamentKey: ornamentKey!,
            family: AppOrnamentFamily.section,
          ),
        );
      },
    );
  }

  Widget _buildCard(
    BuildContext context, {
    AppOrnamentLayout? sessionLayout,
    double ornamentVisibilityFactor = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final resolvedBaseColor =
        baseColor ?? theme.cardTheme.color ?? theme.colorScheme.surface;
    final resolvedStyle =
        ornamentStyle ??
        _resolveOrnamentStyle(accentColor, secondaryColor, radius);
    final startColor = Color.alphaBlend(
      accentColor.withValues(alpha: isDark ? 0.12 : 0.085),
      resolvedBaseColor,
    );
    final endColor = Color.alphaBlend(
      (secondaryColor ?? accentColor).withValues(alpha: isDark ? 0.095 : 0.062),
      resolvedBaseColor,
    );
    final showOrnaments = ornamentVisibilityFactor > 0;
    final ornamentWidgets = showOrnaments
        ? (sessionLayout == null
              ? _buildSectionOrnaments(
                  style: resolvedStyle,
                  isDark: isDark,
                  accentColor: accentColor,
                  secondaryColor: secondaryColor ?? accentColor,
                  visibilityFactor: ornamentVisibilityFactor,
                )
              : _buildSectionOrnamentsForLayout(
                  layout: sessionLayout,
                  isDark: isDark,
                  accentColor: accentColor,
                  secondaryColor: secondaryColor ?? accentColor,
                  visibilityFactor: ornamentVisibilityFactor,
                ))
        : const <Widget>[];
    final ornamentIdentity =
        sessionLayout?.id ?? 'fallback:${resolvedStyle.name}';

    return AppSurfaceCard(
      radius: radius,
      color: resolvedBaseColor,
      borderColor: surfaceBorderColor,
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
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.24, 0.74, 1],
                      colors: [
                        Colors.white.withValues(alpha: isDark ? 0.032 : 0.085),
                        Colors.white.withValues(alpha: isDark ? 0.012 : 0.024),
                        Colors.transparent,
                        Colors.black.withValues(alpha: isDark ? 0.016 : 0.008),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -34,
              right: -12,
              child: IgnorePointer(
                child: Container(
                  width: 132,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: isDark ? 0.08 : 0.11),
                        accentColor.withValues(alpha: 0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            if (showOrnaments)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Stack(
                      key: ValueKey<String>(ornamentIdentity),
                      fit: StackFit.expand,
                      children: ornamentWidgets,
                    ),
                  ),
                ),
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

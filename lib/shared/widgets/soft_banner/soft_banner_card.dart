part of 'soft_banner.dart';

/// 浅色渐变横幅容器。
class SoftBannerCard extends StatelessWidget {
  const SoftBannerCard({
    super.key,
    required this.palette,
    required this.builder,
    this.ornamentKey,
    this.ornamentStyle,
    this.padding = const EdgeInsets.all(18),
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  });

  final SoftBannerPalette palette;

  /// 允许调用方根据 theme 调整前景色（标题、chip、按钮等）。
  final Widget Function(BuildContext context, SoftBannerTheme theme) builder;

  final String? ornamentKey;
  final AppOrnamentStyle? ornamentStyle;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

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
        return _buildCard(
          context,
          ornamentVisibilityFactor: ornamentState.visibilityFactor,
          sessionLayout: ornamentNotifier.resolveLayout(
            ornamentKey: ornamentKey!,
            family: AppOrnamentFamily.banner,
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
    final theme = palette.createTheme();
    final resolvedStyle =
        ornamentStyle ??
        _resolveBannerOrnamentStyle(
          palette.startColor,
          palette.endColor,
          palette.accentColor,
        );
    final showOrnaments = ornamentVisibilityFactor > 0;
    final ornamentWidgets = showOrnaments
        ? (sessionLayout == null
              ? _buildBannerOrnaments(
                  style: resolvedStyle,
                  theme: theme,
                  visibilityFactor: ornamentVisibilityFactor,
                )
              : _buildBannerOrnamentsForLayout(
                  layout: sessionLayout,
                  theme: theme,
                  visibilityFactor: ornamentVisibilityFactor,
                ))
        : const <Widget>[];
    final ornamentIdentity =
        sessionLayout?.id ?? 'fallback:${resolvedStyle.name}';

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
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0, 0.2, 0.62, 1],
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.038),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.014),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -36,
              left: 18,
              right: 18,
              child: IgnorePointer(
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.accentColor.withValues(alpha: 0.09),
                        theme.accentColor.withValues(alpha: 0),
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

part of 'soft_banner.dart';

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
  required double visibilityFactor,
}) {
  return _buildBannerOrnamentsForLayout(
    layout: kBannerFallbackLayouts[style]!,
    theme: theme,
    visibilityFactor: visibilityFactor,
  );
}

List<Widget> _buildBannerOrnamentsForLayout({
  required AppOrnamentLayout layout,
  required SoftBannerTheme theme,
  required double visibilityFactor,
}) {
  return layout.nodes
      .map(
        (node) => _SoftBannerOrnamentNode(
          node: node,
          color: _bannerNodeColor(
            node: node,
            theme: theme,
            visibilityFactor: visibilityFactor,
          ),
          borderColor: _bannerNodeBorderColor(
            node: node,
            theme: theme,
            visibilityFactor: visibilityFactor,
          ),
        ),
      )
      .toList();
}

Color _bannerNodeColor({
  required AppOrnamentNodeSpec node,
  required SoftBannerTheme theme,
  required double visibilityFactor,
}) {
  final secondaryBase = Color.lerp(theme.accentColor, theme.endColor, 0.4)!;
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryBase
      : theme.accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => 0.16,
    AppOrnamentTone.medium => 0.12,
    AppOrnamentTone.light => 0.085,
    AppOrnamentTone.spark => 0.27,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

Color _bannerNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required SoftBannerTheme theme,
  required double visibilityFactor,
}) {
  final secondaryBase = Color.lerp(theme.accentColor, theme.endColor, 0.4)!;
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryBase
      : theme.accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => 0.23,
    AppOrnamentTone.medium => 0.2,
    AppOrnamentTone.light => 0.16,
    AppOrnamentTone.spark => 0.28,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

class _SoftBannerOrnamentNode extends StatelessWidget {
  const _SoftBannerOrnamentNode({
    required this.node,
    required this.color,
    required this.borderColor,
  });

  final AppOrnamentNodeSpec node;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final child = switch (node.shape) {
      AppOrnamentNodeShape.orb => _SoftBannerBlob(
        width: node.width,
        height: node.height,
        color: color,
      ),
      AppOrnamentNodeShape.pill => _SoftBannerPill(
        width: node.width,
        height: node.height,
        color: color,
      ),
      AppOrnamentNodeShape.ring => _SoftBannerRing(
        size: node.width,
        color: color,
        borderColor: borderColor,
      ),
    };

    return Align(
      alignment: node.alignment,
      child: Transform.translate(
        offset: node.offset,
        child: Transform.rotate(angle: node.rotation, child: child),
      ),
    );
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

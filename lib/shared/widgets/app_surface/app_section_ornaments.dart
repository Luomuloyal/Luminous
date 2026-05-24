part of '../app_surface.dart';

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
  required double visibilityFactor,
}) {
  return _buildSectionOrnamentsForLayout(
    layout: kSectionFallbackLayouts[style]!,
    isDark: isDark,
    accentColor: accentColor,
    secondaryColor: secondaryColor,
    visibilityFactor: visibilityFactor,
  );
}

List<Widget> _buildSectionOrnamentsForLayout({
  required AppOrnamentLayout layout,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
  required double visibilityFactor,
}) {
  return layout.nodes
      .map(
        (node) => _SectionOrnamentNode(
          node: node,
          color: _sectionNodeColor(
            node: node,
            isDark: isDark,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            visibilityFactor: visibilityFactor,
          ),
          borderColor: _sectionNodeBorderColor(
            node: node,
            isDark: isDark,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            visibilityFactor: visibilityFactor,
          ),
        ),
      )
      .toList();
}

Color _sectionNodeColor({
  required AppOrnamentNodeSpec node,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.13 : 0.145,
    AppOrnamentTone.medium => isDark ? 0.095 : 0.11,
    AppOrnamentTone.light => isDark ? 0.075 : 0.088,
    AppOrnamentTone.spark => isDark ? 0.18 : 0.23,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

Color _sectionNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.22 : 0.19,
    AppOrnamentTone.medium => isDark ? 0.20 : 0.18,
    AppOrnamentTone.light => isDark ? 0.16 : 0.14,
    AppOrnamentTone.spark => isDark ? 0.24 : 0.22,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

class _SectionOrnamentNode extends StatelessWidget {
  const _SectionOrnamentNode({
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
      AppOrnamentNodeShape.orb => _SectionOrb(size: node.width, color: color),
      AppOrnamentNodeShape.pill => _SectionPill(
        width: node.width,
        height: node.height,
        color: color,
      ),
      AppOrnamentNodeShape.ring => _SectionRing(
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

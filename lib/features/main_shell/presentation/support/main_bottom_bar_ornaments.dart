part of '../main_shell.dart';

List<Widget> _buildBottomBarOrnaments({
  required AppOrnamentLayout layout,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
  required double globalShiftX,
}) {
  return layout.nodes
      .map(
        (node) => _BottomBarOrnamentNode(
          node: node,
          globalShiftX: globalShiftX,
          color: _bottomBarNodeColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
            visibilityFactor: visibilityFactor,
          ),
          borderColor: _bottomBarNodeBorderColor(
            node: node,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
            isDark: isDark,
            visibilityFactor: visibilityFactor,
          ),
        ),
      )
      .toList();
}

Color _bottomBarNodeColor({
  required AppOrnamentNodeSpec node,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.20 : 0.13,
    AppOrnamentTone.medium => isDark ? 0.15 : 0.10,
    AppOrnamentTone.light => isDark ? 0.10 : 0.07,
    AppOrnamentTone.spark => isDark ? 0.23 : 0.16,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

Color _bottomBarNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required Color accentColor,
  required Color secondaryColor,
  required bool isDark,
  required double visibilityFactor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final baseAlpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.24 : 0.16,
    AppOrnamentTone.medium => isDark ? 0.20 : 0.13,
    AppOrnamentTone.light => isDark ? 0.16 : 0.10,
    AppOrnamentTone.spark => isDark ? 0.28 : 0.18,
  };
  final alpha = resolveOrnamentAlpha(
    baseAlpha: baseAlpha,
    visibilityFactor: visibilityFactor,
  );
  return base.withValues(alpha: alpha);
}

class _BottomBarOrnamentNode extends StatelessWidget {
  const _BottomBarOrnamentNode({
    required this.node,
    required this.color,
    required this.borderColor,
    required this.globalShiftX,
  });

  final AppOrnamentNodeSpec node;
  final Color color;
  final Color borderColor;
  final double globalShiftX;

  static const double _sizeScale = 0.58;
  static const double _offsetScale = 0.26;

  @override
  Widget build(BuildContext context) {
    final width = node.width * _sizeScale;
    final height = node.height * _sizeScale;
    final child = switch (node.shape) {
      AppOrnamentNodeShape.orb => _BottomBarOrb(size: width, color: color),
      AppOrnamentNodeShape.pill => _BottomBarPill(
        width: width,
        height: height,
        color: color,
      ),
      AppOrnamentNodeShape.ring => _BottomBarRing(
        size: width,
        color: color,
        borderColor: borderColor,
      ),
    };

    return Align(
      alignment: node.alignment,
      child: Transform.translate(
        offset: Offset(
          (node.offset.dx * _offsetScale) + globalShiftX,
          node.offset.dy * _offsetScale,
        ),
        child: Transform.rotate(angle: node.rotation, child: child),
      ),
    );
  }
}

class _BottomBarOrb extends StatelessWidget {
  const _BottomBarOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

class _BottomBarPill extends StatelessWidget {
  const _BottomBarPill({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _BottomBarRing extends StatelessWidget {
  const _BottomBarRing({
    required this.size,
    required this.color,
    required this.borderColor,
  });

  final double size;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: borderColor, width: 1.2),
      ),
    );
  }
}

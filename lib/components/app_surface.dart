import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_ornaments.dart';
import 'package:luminous/stores/ornament_controller.dart';

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
    this.ornamentKey,
    this.ornamentStyle,
    this.padding = const EdgeInsets.all(14),
    this.radius = 18,
  });

  final Widget child;
  final Color accentColor;
  final Color? secondaryColor;
  final String? ornamentKey;
  final AppOrnamentStyle? ornamentStyle;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (ornamentKey == null) {
      return _buildCard(context);
    }
    final ornamentController = Get.find<OrnamentController>();
    return Obx(() {
      ornamentController.revision.value;
      return _buildCard(
        context,
        sessionLayout: ornamentController.resolveLayout(
          ornamentKey: ornamentKey!,
          family: AppOrnamentFamily.section,
        ),
      );
    });
  }

  Widget _buildCard(BuildContext context, {AppOrnamentLayout? sessionLayout}) {
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
    final ornamentWidgets = sessionLayout == null
        ? _buildSectionOrnaments(
            style: resolvedStyle,
            isDark: isDark,
            accentColor: accentColor,
            secondaryColor: secondaryColor ?? accentColor,
          )
        : _buildSectionOrnamentsForLayout(
            layout: sessionLayout,
            isDark: isDark,
            accentColor: accentColor,
            secondaryColor: secondaryColor ?? accentColor,
          );
    final ornamentIdentity =
        sessionLayout?.id ?? 'fallback:${resolvedStyle.name}';

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
  return _buildSectionOrnamentsForLayout(
    layout: kSectionFallbackLayouts[style]!,
    isDark: isDark,
    accentColor: accentColor,
    secondaryColor: secondaryColor,
  );
}

List<Widget> _buildSectionOrnamentsForLayout({
  required AppOrnamentLayout layout,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
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
          ),
          borderColor: _sectionNodeBorderColor(
            node: node,
            isDark: isDark,
            accentColor: accentColor,
            secondaryColor: secondaryColor,
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
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final alpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.13 : 0.145,
    AppOrnamentTone.medium => isDark ? 0.095 : 0.11,
    AppOrnamentTone.light => isDark ? 0.075 : 0.088,
    AppOrnamentTone.spark => isDark ? 0.18 : 0.23,
  };
  return base.withValues(alpha: alpha);
}

Color _sectionNodeBorderColor({
  required AppOrnamentNodeSpec node,
  required bool isDark,
  required Color accentColor,
  required Color secondaryColor,
}) {
  final base = node.colorRole == AppOrnamentColorRole.secondary
      ? secondaryColor
      : accentColor;
  final alpha = switch (node.tone) {
    AppOrnamentTone.strong => isDark ? 0.22 : 0.19,
    AppOrnamentTone.medium => isDark ? 0.20 : 0.18,
    AppOrnamentTone.light => isDark ? 0.16 : 0.14,
    AppOrnamentTone.spark => isDark ? 0.24 : 0.22,
  };
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

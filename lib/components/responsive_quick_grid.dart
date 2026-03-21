import 'package:flutter/material.dart';

/// 项目内供快捷入口网格复用的响应式尺寸配置。
///
/// - 小于 600dp 时启用手机端紧凑布局；
/// - Web/平板维持现有较宽松的尺寸和固定高度。
bool isCompactLayoutWidth(double maxWidth) => maxWidth < 600;

class ResponsiveQuickGridMetrics {
  const ResponsiveQuickGridMetrics._({
    required this.isCompact,
    required this.sectionPadding,
    required this.gridSpacing,
    required this.itemPadding,
    required this.iconBoxSize,
    required this.iconSize,
    required this.iconBorderRadius,
    required this.titleSpacing,
    required this.subtitleSpacing,
    required this.gridDelegate,
  });

  factory ResponsiveQuickGridMetrics.fromWidth(double maxWidth) {
    final compact = isCompactLayoutWidth(maxWidth);
    final spacing = compact ? 10.0 : 12.0;
    final safeWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 360.0;
    final cellWidth = ((safeWidth - (spacing * 2)) / 3).clamp(
      0.0,
      double.infinity,
    );
    final compactIconBox = (cellWidth * 0.56).clamp(52.0, 64.0).toDouble();

    return ResponsiveQuickGridMetrics._(
      isCompact: compact,
      sectionPadding: compact ? 12.0 : 14.0,
      gridSpacing: spacing,
      itemPadding: compact
          ? const EdgeInsets.fromLTRB(8, 8, 8, 8)
          : const EdgeInsets.fromLTRB(10, 12, 10, 12),
      iconBoxSize: compact ? compactIconBox : 74.0,
      iconSize: compact
          ? (compactIconBox * 0.5).clamp(26.0, 32.0).toDouble()
          : 38.0,
      iconBorderRadius: compact ? 18.0 : 22.0,
      titleSpacing: compact ? 8.0 : 12.0,
      subtitleSpacing: compact ? 2.0 : 3.0,
      gridDelegate: compact
          ? SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              childAspectRatio: 0.82,
            )
          : const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 156,
            ),
    );
  }

  /// 当前是否处于手机窄屏布局。
  final bool isCompact;

  /// 外层白卡内容区 padding。
  final double sectionPadding;

  /// 网格行列间距。
  final double gridSpacing;

  /// 单个入口卡片的内部 padding。
  final EdgeInsets itemPadding;

  /// 图标背景方块边长。
  final double iconBoxSize;

  /// 图标大小。
  final double iconSize;

  /// 图标背景圆角。
  final double iconBorderRadius;

  /// 图标与标题之间的间距。
  final double titleSpacing;

  /// 标题与副标题之间的间距。
  final double subtitleSpacing;

  /// 当前宽度对应的网格委托。
  final SliverGridDelegateWithFixedCrossAxisCount gridDelegate;
}

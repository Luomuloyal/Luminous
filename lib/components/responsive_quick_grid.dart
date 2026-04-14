import 'package:flutter/material.dart';

/// 项目内供快捷入口网格复用的响应式尺寸配置。
///
/// - 小于 600dp 时启用手机端紧凑布局；
/// - Web/平板维持现有较宽松的尺寸和固定高度。
bool isCompactLayoutWidth(double maxWidth) => maxWidth < 600;

class ResponsiveQuickGridMetrics {
  const ResponsiveQuickGridMetrics._({
    required this.isCompact,
    required this.columnCount,
    required this.itemWidth,
    required this.sectionPadding,
    required this.gridSpacing,
    required this.itemPadding,
    required this.iconBoxSize,
    required this.iconSize,
    required this.iconBorderRadius,
    required this.titleSpacing,
    required this.subtitleSpacing,
  });

  factory ResponsiveQuickGridMetrics.fromWidth(
    double maxWidth, {
    double textScaleFactor = 1.0,
  }) {
    final compact = isCompactLayoutWidth(maxWidth);
    final spacing = compact ? 6.0 : 10.0;
    final safeWidth = maxWidth.isFinite && maxWidth > 0 ? maxWidth : 360.0;
    final resolvedTextScale = textScaleFactor.clamp(1.0, 1.6).toDouble();
    final columnCount = compact && resolvedTextScale > 1.2 && safeWidth < 420
        ? 2
        : 3;
    final cellWidth =
        ((safeWidth - (spacing * (columnCount - 1))) / columnCount)
            .clamp(0.0, double.infinity)
            .toDouble();
    final compactIconBox = (cellWidth * 0.45).clamp(42.0, 52.0).toDouble();

    return ResponsiveQuickGridMetrics._(
      isCompact: compact,
      columnCount: columnCount,
      itemWidth: cellWidth,
      sectionPadding: compact ? 8.0 : 12.0,
      gridSpacing: spacing,
      itemPadding: compact
          ? const EdgeInsets.fromLTRB(4, 6, 4, 6)
          : const EdgeInsets.fromLTRB(8, 10, 8, 10),
      iconBoxSize: compact ? compactIconBox : 64.0,
      iconSize: compact
          ? (compactIconBox * 0.5).clamp(22.0, 28.0).toDouble()
          : 32.0,
      iconBorderRadius: compact ? 14.0 : 18.0,
      titleSpacing: compact ? 4.0 : 8.0,
      subtitleSpacing: compact ? 1.0 : 2.0,
    );
  }

  /// 当前是否处于手机窄屏布局。
  final bool isCompact;

  /// 当前宽度和字号下建议的列数。
  final int columnCount;

  /// 当前布局中单个入口卡片的建议宽度。
  final double itemWidth;

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
}

/// 自适应快捷入口布局，允许卡片按内容自然增高。
class ResponsiveQuickWrap extends StatelessWidget {
  const ResponsiveQuickWrap({
    super.key,
    required this.metrics,
    required this.itemCount,
    required this.itemBuilder,
  });

  final ResponsiveQuickGridMetrics metrics;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final safeWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : metrics.itemWidth * metrics.columnCount;
        final computedItemWidth =
            ((safeWidth - (metrics.gridSpacing * (metrics.columnCount - 1))) /
                    metrics.columnCount)
                .clamp(0.0, double.infinity)
                .toDouble();
        final resolvedItemWidth = computedItemWidth > 0
            ? computedItemWidth
            : metrics.itemWidth;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: metrics.gridSpacing,
          runSpacing: metrics.gridSpacing,
          children: List.generate(
            itemCount,
            (index) => SizedBox(
              width: resolvedItemWidth,
              child: itemBuilder(context, index),
            ),
          ),
        );
      },
    );
  }
}

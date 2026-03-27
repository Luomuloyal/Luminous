import 'package:flutter/material.dart';
import 'package:luminous/components/responsive_quick_grid.dart';

/// 我的页（Mine）相关的小型展示模型与卡片组件。
class MineQuickActionData {
  /// 创建一个快捷操作数据对象。
  const MineQuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.id,
  });

  /// 快捷操作图标。
  final IconData icon;

  /// 快捷操作标题。
  final String title;

  /// 快捷操作副标题。
  final String subtitle;

  /// 快捷操作主色。
  final Color color;

  /// 快捷操作唯一标识。
  ///
  /// 页面通常会根据它决定点击后执行什么逻辑。
  final String id;
}

/// 我的页顶部“快捷入口”区域中的单个卡片组件。
class MineQuickActionCard extends StatelessWidget {
  /// 创建一个快捷操作卡片组件。
  const MineQuickActionCard({
    super.key,
    required this.data,
    required this.onTap,
    this.metrics,
  });

  /// 当前卡片使用的数据对象。
  final MineQuickActionData data;

  /// 点击卡片回调。
  final VoidCallback onTap;

  /// 由外层网格计算好的响应式尺寸。
  final ResponsiveQuickGridMetrics? metrics;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final resolvedMetrics =
              metrics ??
              ResponsiveQuickGridMetrics.fromWidth(constraints.maxWidth);
          final compact = resolvedMetrics.isCompact;
          final theme = Theme.of(context);
          final scheme = theme.colorScheme;
          final isDark = theme.brightness == Brightness.dark;
          final cardBackground = Color.alphaBlend(
            data.color.withValues(alpha: isDark ? 0.10 : 0.055),
            isDark ? scheme.surface : Colors.white,
          );
          final cardBorder = Color.alphaBlend(
            data.color.withValues(alpha: isDark ? 0.28 : 0.14),
            scheme.outline,
          );

          return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Ink(
              padding: resolvedMetrics.itemPadding,
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? Colors.black : data.color).withValues(
                      alpha: isDark ? 0.14 : 0.08,
                    ),
                    blurRadius: isDark ? 16 : 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    child: SizedBox(
                      width: resolvedMetrics.iconBoxSize,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                data.color.withValues(
                                  alpha: isDark ? 0.26 : 0.20,
                                ),
                                data.color.withValues(
                                  alpha: isDark ? 0.15 : 0.11,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              resolvedMetrics.iconBorderRadius,
                            ),
                            border: Border.all(
                              color: data.color.withValues(
                                alpha: isDark ? 0.38 : 0.26,
                              ),
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            color: data.color,
                            size: resolvedMetrics.iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: resolvedMetrics.titleSpacing),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: compact ? 14 : 14.5,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: resolvedMetrics.subtitleSpacing),
                        Flexible(
                          child: Text(
                            data.subtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: compact ? 11.5 : 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurfaceVariant,
                              height: compact ? 1.2 : 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

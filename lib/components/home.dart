import 'package:flutter/material.dart';
import 'package:luminous/components/responsive_quick_grid.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/viewmodels/home.dart';

/// 首页（Home）可复用的 UI 组件集合。
///
/// 该文件的组件会被 [lib/pages/Home/home.dart] 组合使用，页面本身只负责：
/// - 数据加载与状态维护；
/// - 路由跳转；
/// 具体 UI（卡片布局、列表样式等）在这里统一维护。
class HomeFeatureItemData {
  /// 功能入口的唯一 id（用于点击分发）。
  final String id;

  /// 功能入口标题。
  final String title;

  /// 功能入口副标题。
  final String subtitle;

  /// 功能入口图标。
  final IconData icon;

  /// 功能入口主题色。
  final Color color;

  /// 创建一个“常用功能”入口数据对象。
  const HomeFeatureItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class HomeReminderItemData {
  /// 提醒左侧图标。
  final IconData icon;

  /// 提醒标题（通常为时间 + 药品名）。
  final String title;

  /// 提醒副标题（服用说明等）。
  final String subtitle;

  /// 当前提醒是否已完成。
  final bool done;

  /// 创建一个首页提醒条目数据对象。
  const HomeReminderItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });
}

/// “常用功能”卡片区域。
///
/// 该组件只负责展示入口网格，点击行为通过 `onTap` 交给页面处理。
class HomeFeatureSection extends StatelessWidget {
  const HomeFeatureSection({
    super.key,
    required this.items,
    required this.onTap,
  });

  /// 要展示的功能入口列表。
  final List<HomeFeatureItemData> items;

  /// 点击入口回调。
  final ValueChanged<HomeFeatureItemData> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final metrics = ResponsiveQuickGridMetrics.fromWidth(
            constraints.maxWidth - ((compact ? 12 : 14) * 2),
          );

          return _HomeSectionCard(
            padding: EdgeInsets.all(metrics.sectionPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '常用功能',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                const Text(
                  '快速进入核心健康服务',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                SizedBox(height: compact ? 12 : 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: metrics.gridDelegate,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _HomeFeatureGridItem(
                      item: item,
                      metrics: metrics,
                      onTap: () => onTap(item),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// “今日提醒”卡片区域。
///
/// 该组件只负责渲染提醒列表，不包含数据请求逻辑。
class HomeReminderSection extends StatelessWidget {
  const HomeReminderSection({super.key, required this.items});

  /// 提醒条目列表。
  final List<HomeReminderItemData> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          return _HomeSectionCard(
            padding: EdgeInsets.all(compact ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '今日提醒',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: compact ? 8 : 10),
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == items.length - 1 ? 0 : (compact ? 6 : 8),
                    ),
                    child: _HomeReminderTile(item: item, compact: compact),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 首页顶部“健康助手”区域。
///
/// 页面会把随机温馨提示、下一条提醒文案、加载状态等注入进来渲染。
class HomeTopSection extends StatelessWidget {
  const HomeTopSection({
    super.key,
    required this.palette,
    required this.todayTip,
    required this.nextText,
    required this.loadingReminders,
    required this.reminderCount,
    required this.onTapTip,
  });

  /// 顶部横幅配色。
  final SoftBannerPalette palette;

  /// 顶部随机提示文案。
  final String todayTip;

  /// 下一条提醒文案（已在页面层拼接好）。
  final String nextText;

  /// 是否正在加载提醒数据。
  final bool loadingReminders;

  /// 当前提醒条数。
  final int reminderCount;

  /// 点击“健康小贴士”回调。
  final VoidCallback onTapTip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);

          return SoftBannerCard(
            palette: palette,
            padding: EdgeInsets.all(compact ? 16 : 18),
            builder: (context, theme) {
              final pills = <Widget>[
                HomeInfoPill(
                  text: loadingReminders ? '提醒加载中...' : '今日提醒 $reminderCount 条',
                  backgroundColor: theme.surfaceColor,
                  textColor: theme.surfaceTextColor,
                ),
                HomeInfoPill(
                  text: '健康小贴士',
                  backgroundColor: theme.surfaceColor,
                  textColor: theme.surfaceTextColor,
                  onTap: onTapTip,
                ),
              ];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: compact ? 38 : 40,
                        height: compact ? 38 : 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.86),
                          border: Border.all(color: theme.borderColor),
                        ),
                        child: Icon(
                          Icons.favorite_outline,
                          color: theme.accentColor,
                          size: compact ? 20 : 24,
                        ),
                      ),
                      SizedBox(width: compact ? 8 : 10),
                      Expanded(
                        child: Text(
                          '健康助手',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: compact ? 19 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      HomeStatusChip(
                        text: '已同步',
                        backgroundColor: theme.surfaceColor,
                        textColor: theme.surfaceTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 14 : 16),
                  Text(
                    todayTip,
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: compact ? 15 : 16,
                      fontWeight: FontWeight.w700,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: compact ? 6 : 8),
                  Text(
                    nextText,
                    style: TextStyle(
                      color: theme.secondaryTextColor,
                      fontSize: compact ? 13.5 : 14,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 14),
                  compact
                      ? Wrap(spacing: 8, runSpacing: 8, children: pills)
                      : Row(
                          children: [
                            pills.first,
                            const SizedBox(width: 8),
                            pills.last,
                          ],
                        ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 14),
  });

  /// 卡片内部要展示的内容。
  final Widget child;

  /// 卡片内边距。
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HomeReminderTile extends StatelessWidget {
  const _HomeReminderTile({required this.item, required this.compact});

  /// 当前提醒条目数据。
  final HomeReminderItemData item;

  /// 当前是否使用手机端紧凑布局。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: item.done ? const Color(0xFFEFFCF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: item.done ? const Color(0xFFBBF7D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 30 : 32,
            height: compact ? 30 : 32,
            decoration: BoxDecoration(
              color: item.done
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(compact ? 8 : 9),
            ),
            child: Icon(
              item.icon,
              color: item.done
                  ? const Color(0xFF16A34A)
                  : const Color(0xFF0284C7),
              size: compact ? 17 : 18,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: compact ? 13.5 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1.5 : 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: compact ? 11.5 : 12,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.done
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeFeatureGridItem extends StatelessWidget {
  const _HomeFeatureGridItem({
    required this.item,
    required this.metrics,
    required this.onTap,
  });

  final HomeFeatureItemData item;
  final ResponsiveQuickGridMetrics metrics;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = metrics.isCompact;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: metrics.itemPadding,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              child: SizedBox(
                width: metrics.iconBoxSize,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(
                        metrics.iconBorderRadius,
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      size: metrics.iconSize,
                      color: item.color,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: metrics.titleSpacing),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 14 : 14.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: metrics.subtitleSpacing),
                  Flexible(
                    child: Text(
                      item.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: compact ? 11.5 : 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
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
  }
}

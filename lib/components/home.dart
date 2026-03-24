import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.primary, scheme.secondary, 0.35)!;
    final secondary = Color.lerp(scheme.secondary, scheme.tertiary, 0.45)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final metrics = ResponsiveQuickGridMetrics.fromWidth(
            constraints.maxWidth - ((compact ? 12 : 14) * 2),
          );

          return AppSectionCard(
            accentColor: accent,
            secondaryColor: secondary,
            ornamentKey: 'home.features',
            padding: EdgeInsets.all(metrics.sectionPadding),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '常用功能',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '快速进入核心健康服务',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          return AppSectionCard(
            accentColor: Color.lerp(scheme.tertiary, scheme.primary, 0.35)!,
            secondaryColor: Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
            ornamentKey: 'home.reminders',
            padding: EdgeInsets.all(compact ? 12 : 14),
            radius: 18,
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
    required this.todayTipListenable,
    required this.nextText,
    required this.loadingReminders,
    required this.reminderCount,
    required this.onTapTip,
    required this.onLongPressTip,
  });

  /// 顶部横幅配色。
  final SoftBannerPalette palette;

  /// 顶部随机提示文案监听器。
  final ValueListenable<String> todayTipListenable;

  /// 下一条提醒文案（已在页面层拼接好）。
  final String nextText;

  /// 是否正在加载提醒数据。
  final bool loadingReminders;

  /// 当前提醒条数。
  final int reminderCount;

  /// 点击“健康小贴士”回调。
  final VoidCallback onTapTip;

  /// 长按“健康小贴士”回调。
  final VoidCallback onLongPressTip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);

          return SoftBannerCard(
            palette: palette,
            ornamentKey: 'home.banner',
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
                  onLongPress: onLongPressTip,
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
                          color: theme.surfaceColor,
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
                  ValueListenableBuilder<String>(
                    valueListenable: todayTipListenable,
                    builder: (context, todayTip, _) {
                      final minTipHeight = compact ? 24.0 : 26.0;

                      return ConstrainedBox(
                        constraints: BoxConstraints(minHeight: minTipHeight),
                        child: ClipRect(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 240),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            layoutBuilder: (currentChild, previousChildren) {
                              final currentChildren = currentChild == null
                                  ? null
                                  : <Widget>[currentChild];

                              return Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ...previousChildren,
                                  ...?currentChildren,
                                ],
                              );
                            },
                            transitionBuilder: (child, animation) {
                              final isIncoming =
                                  child.key == ValueKey<String>(todayTip);
                              final offsetAnimation = animation.drive(
                                Tween<Offset>(
                                  begin: isIncoming
                                      ? const Offset(0, 0.35)
                                      : const Offset(0, -0.22),
                                  end: Offset.zero,
                                ),
                              );

                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              todayTip,
                              key: ValueKey<String>(todayTip),
                              style: TextStyle(
                                color: theme.textColor,
                                fontSize: compact ? 15 : 16,
                                fontWeight: FontWeight.w700,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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

class _HomeReminderTile extends StatelessWidget {
  const _HomeReminderTile({required this.item, required this.compact});

  /// 当前提醒条目数据。
  final HomeReminderItemData item;

  /// 当前是否使用手机端紧凑布局。
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final idleBackground = isDark
        ? const Color(0xFF172234)
        : const Color(0xFFF8FAFC);
    final idleBorder = isDark
        ? const Color(0xFF314257)
        : const Color(0xFFE2E8F0);
    final doneBackground = isDark
        ? const Color(0xFF12271F)
        : const Color(0xFFEFFCF5);
    final doneBorder = isDark
        ? const Color(0xFF23513E)
        : const Color(0xFFBBF7D0);
    final idleIconBackground = isDark
        ? const Color(0xFF17324B)
        : const Color(0xFFEFF6FF);
    final doneIconBackground = isDark
        ? const Color(0xFF173427)
        : const Color(0xFFDCFCE7);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: item.done ? doneBackground : idleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.done ? doneBorder : idleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 30 : 32,
            height: compact ? 30 : 32,
            decoration: BoxDecoration(
              color: item.done ? doneIconBackground : idleIconBackground,
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
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1.5 : 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: compact ? 11.5 : 12,
                    color: subtitleColor,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: metrics.itemPadding,
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
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF64748B),
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

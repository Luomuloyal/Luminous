import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/responsive_quick_grid.dart';
import 'package:luminous/components/shared_quick_entry_card.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/home.dart';

/// 首页（Home）可复用的 UI 组件集合。
///
/// 该文件的组件会被 [lib/pages/Home/home.dart] 组合使用，页面本身只负责：
/// - 数据加载与状态维护；
/// - 路由跳转；
/// 具体 UI（卡片布局、列表样式等）在这里统一维护。

/// 首页顶部卡片中的状态 chip（例如“已同步”）。
class HomeStatusChip extends StatelessWidget {
  /// 创建一个状态 chip。
  const HomeStatusChip({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.textColor = Colors.white,
  });

  /// chip 上展示的文本。
  final String text;

  /// chip 背景色。
  final Color backgroundColor;

  /// chip 文字色。
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TintedStatusChip(
      text: text,
      color: textColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    );
  }
}

/// 首页顶部卡片中的信息 pill（例如“今日提醒 3 条”）。
class HomeInfoPill extends StatelessWidget {
  /// 创建一个信息 pill。
  const HomeInfoPill({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x29FFFFFF),
    this.textColor = Colors.white,
    this.onTap,
    this.onLongPress,
  });

  /// pill 上展示的文本。
  final String text;

  /// pill 背景色。
  final Color backgroundColor;

  /// pill 文字色。
  final Color textColor;

  /// 点击回调。
  final VoidCallback? onTap;

  /// 长按回调。
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final content = TintedStatusChip(
      text: text,
      color: textColor,
      backgroundColor: backgroundColor,
      showBorder: false,
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      enablePopup: onTap == null && onLongPress == null,
    );

    if (onTap == null && onLongPress == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)),
          child: content,
        ),
      ),
    );
  }
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
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.primary, scheme.secondary, 0.35)!;
    final secondary = Color.lerp(scheme.secondary, scheme.tertiary, 0.45)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
          final metrics = ResponsiveQuickGridMetrics.fromWidth(
            constraints.maxWidth,
            textScaleFactor: textScaleFactor,
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
                Text(
                  l10n?.homeFeaturesTitle ?? '常用功能',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.homeFeaturesSubtitle ?? '快速进入核心健康服务',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                ResponsiveQuickWrap(
                  metrics: metrics,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return SharedQuickEntryCard(
                      icon: item.icon,
                      title: item.title,
                      subtitle: item.subtitle,
                      color: item.color,
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
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    final emptyText = locale.startsWith('zh')
        ? '暂未设置任何提醒'
        : (l10n?.homeNoReminder ?? 'No reminders');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final minListHeight =
              (compact ? 48.0 : 54.0) * 3 + (compact ? 6.0 : 8.0) * 2;
          return AppSectionCard(
            accentColor: Color.lerp(scheme.tertiary, scheme.primary, 0.35)!,
            secondaryColor: Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
            ornamentKey: 'home.reminders',
            padding: EdgeInsets.all(compact ? 10 : 12),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeReminderTitle ?? '今日提醒',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 5 : 7),
                if (items.isEmpty)
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minListHeight),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 10 : 12,
                        vertical: compact ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          context,
                          scheme.primary,
                          lightAlpha: 0.08,
                          darkAlpha: 0.16,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: appTintedBorder(
                            context,
                            scheme.primary,
                            lightAlpha: 0.12,
                            darkAlpha: 0.22,
                          ),
                        ),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        emptyText,
                        style: TextStyle(
                          fontSize: compact ? 13 : 13.5,
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minListHeight),
                    child: Column(
                      children: items
                          .asMap()
                          .entries
                          .map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == items.length - 1
                                    ? 0
                                    : (compact ? 6 : 8),
                              ),
                              child: _HomeReminderTile(
                                item: item,
                                compact: compact,
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// 首页“打卡记录”卡片区域。
class HomeCheckInRecordSection extends StatelessWidget {
  const HomeCheckInRecordSection({super.key, required this.items});

  /// 打卡记录条目（已按日期倒序、同日内按时间倒序）。
  final List<HomeCheckInRecordData> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context);
    final grouped = _groupByDate(items);
    final emptyText =
        l10n?.homeCheckInRecordsEmpty ?? 'No check-in records yet';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final spacing = compact ? 7.0 : 9.0;
          return AppSectionCard(
            accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.36)!,
            secondaryColor: Color.lerp(
              scheme.tertiary,
              scheme.secondary,
              0.42,
            )!,
            ornamentKey: 'home.checkin-records',
            padding: EdgeInsets.all(compact ? 10 : 12),
            radius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.homeCheckInRecordsTitle ?? 'Check-in Records',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: compact ? 3 : 5),
                Text(
                  l10n?.homeCheckInRecordsSubtitle ??
                      'Daily completion and actual check-in time',
                  style: TextStyle(
                    fontSize: compact ? 12.4 : 12.9,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: compact ? 8 : 10),
                if (grouped.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 11 : 12,
                      vertical: compact ? 14 : 16,
                    ),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.secondary,
                        lightAlpha: 0.08,
                        darkAlpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.secondary,
                          lightAlpha: 0.13,
                          darkAlpha: 0.22,
                        ),
                      ),
                    ),
                    child: Text(
                      emptyText,
                      style: TextStyle(
                        fontSize: compact ? 13 : 13.4,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Column(
                    children: grouped.entries
                        .map((entry) {
                          final dayItems = entry.value;
                          final doneCount = dayItems
                              .where((item) => item.done)
                              .length;
                          final dayLabel = _formatRecordDayLabel(
                            l10n,
                            locale,
                            entry.key,
                          );
                          final countText =
                              l10n?.homeCheckInRecordsDoneCount(
                                doneCount,
                                dayItems.length,
                              ) ??
                              '$doneCount/${dayItems.length} done';
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: entry.key == grouped.keys.last
                                  ? 0
                                  : spacing,
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(
                                compact ? 9 : 11,
                                compact ? 8 : 9,
                                compact ? 9 : 11,
                                compact ? 9 : 10,
                              ),
                              decoration: BoxDecoration(
                                color: appTintedSurface(
                                  context,
                                  scheme.primary,
                                  lightAlpha: 0.07,
                                  darkAlpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: appTintedBorder(
                                    context,
                                    scheme.primary,
                                    lightAlpha: 0.13,
                                    darkAlpha: 0.22,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        dayLabel,
                                        style: TextStyle(
                                          fontSize: compact ? 12.8 : 13.4,
                                          fontWeight: FontWeight.w800,
                                          color: scheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: appTintedSurface(
                                            context,
                                            scheme.secondary,
                                            lightAlpha: 0.13,
                                            darkAlpha: 0.20,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                        ),
                                        child: Text(
                                          countText,
                                          style: TextStyle(
                                            fontSize: 11.2,
                                            fontWeight: FontWeight.w700,
                                            color: scheme.secondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 7 : 8),
                                  Column(
                                    children: dayItems
                                        .asMap()
                                        .entries
                                        .map((row) {
                                          final index = row.key;
                                          final item = row.value;
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              bottom:
                                                  index == dayItems.length - 1
                                                  ? 0
                                                  : (compact ? 6 : 7),
                                            ),
                                            child: _HomeCheckInRecordTile(
                                              item: item,
                                              compact: compact,
                                              l10n: l10n,
                                            ),
                                          );
                                        })
                                        .toList(growable: false),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<HomeCheckInRecordData>> _groupByDate(
    List<HomeCheckInRecordData> records,
  ) {
    final grouped = <String, List<HomeCheckInRecordData>>{};
    for (final item in records) {
      grouped
          .putIfAbsent(item.dateKey, () => <HomeCheckInRecordData>[])
          .add(item);
    }
    return grouped;
  }

  String _formatRecordDayLabel(
    AppLocalizations? l10n,
    Locale locale,
    String dateKey,
  ) {
    final parsed = _parseDateKey(dateKey);
    if (parsed == null) {
      return dateKey;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    final delta = today.difference(day).inDays;
    if (delta == 0) {
      return l10n?.homeCheckInRecordsToday ?? 'Today';
    }
    if (delta == 1) {
      return l10n?.homeCheckInRecordsYesterday ?? 'Yesterday';
    }
    if (now.year == parsed.year) {
      final month = parsed.month.toString().padLeft(2, '0');
      final dayText = parsed.day.toString().padLeft(2, '0');
      return '$month/$dayText';
    }
    final month = parsed.month.toString().padLeft(2, '0');
    final dayText = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}-$month-$dayText';
  }

  DateTime? _parseDateKey(String value) {
    final text = value.trim();
    if (text.length != 10) {
      return null;
    }
    final year = int.tryParse(text.substring(0, 4));
    final month = int.tryParse(text.substring(5, 7));
    final day = int.tryParse(text.substring(8, 10));
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime(year, month, day);
  }
}

class _HomeCheckInRecordTile extends StatelessWidget {
  const _HomeCheckInRecordTile({
    required this.item,
    required this.compact,
    required this.l10n,
  });

  final HomeCheckInRecordData item;
  final bool compact;
  final AppLocalizations? l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final doneColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.34,
    )!;
    final pendingColor = Color.lerp(
      const Color(0xFFF59E0B),
      scheme.secondary,
      0.25,
    )!;
    final accent = item.done ? doneColor : pendingColor;
    final title = item.reminderTime.trim().isEmpty
        ? item.title.trim()
        : '${item.reminderTime.trim()} ${item.title.trim()}';
    final statusText = item.done
        ? (l10n?.homeCheckInRecordsStatusDone ?? 'Done')
        : (l10n?.homeCheckInRecordsStatusPending ?? 'Pending');
    final detailText = item.done
        ? (l10n?.homeCheckInRecordsCheckedAt(_formatClock(item.takenAt)) ??
              'Checked at ${_formatClock(item.takenAt)}')
        : (l10n?.homeCheckInRecordsNotChecked ?? 'Not checked in');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 8 : 9,
        compact ? 7 : 8,
        compact ? 8 : 9,
        compact ? 7 : 8,
      ),
      decoration: BoxDecoration(
        color: appTintedSurface(
          context,
          accent,
          lightAlpha: 0.09,
          darkAlpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: appTintedBorder(
            context,
            accent,
            lightAlpha: 0.16,
            darkAlpha: 0.25,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 24 : 26,
            height: compact ? 24 : 26,
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accent,
                lightAlpha: 0.18,
                darkAlpha: 0.25,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              item.done ? Icons.check_rounded : Icons.schedule_rounded,
              color: accent,
              size: compact ? 14 : 15,
            ),
          ),
          SizedBox(width: compact ? 7 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.trim().isEmpty
                      ? (l10n?.checkInDefaultTitle ?? 'Medication Reminder')
                      : title,
                  style: TextStyle(
                    fontSize: compact ? 12.4 : 13.0,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                    height: 1.24,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1 : 2),
                Text(
                  detailText,
                  style: TextStyle(
                    fontSize: compact ? 11.1 : 11.6,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 6 : 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accent,
                lightAlpha: 0.16,
                darkAlpha: 0.24,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10.8,
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatClock(int? millis) {
    if (millis == null || millis <= 0) {
      return '--:--';
    }
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);
          final statusText = loadingReminders
              ? (l10n?.homeStatusSyncing ?? '同步中')
              : reminderCount == 0
              ? (l10n?.homeStatusRelaxed ?? '今天较轻松')
              : (l10n?.homeStatusReady ?? '已整理');

          return SoftBannerCard(
            palette: palette,
            ornamentKey: 'home.banner',
            padding: EdgeInsets.all(compact ? 14 : 17),
            builder: (context, theme) {
              final pills = <Widget>[
                HomeInfoPill(
                  text: loadingReminders
                      ? (l10n?.homePillLoading ?? '提醒加载中...')
                      : (l10n?.homePillCount(reminderCount) ??
                            '今日提醒 $reminderCount 条'),
                  backgroundColor: theme.surfaceColor,
                  textColor: theme.surfaceTextColor,
                ),
                HomeInfoPill(
                  text: l10n?.homePillTips ?? '健康小贴士',
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
                          l10n?.homeHeroTitle ?? '健康助手',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: compact ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      HomeStatusChip(
                        text: statusText,
                        backgroundColor: theme.surfaceColor,
                        textColor: theme.surfaceTextColor,
                      ),
                    ],
                  ),
                  SizedBox(height: compact ? 6 : 8),
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
                                fontSize: compact ? 15.2 : 17,
                                fontWeight: FontWeight.w800,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: compact ? 10 : 13),
                  _HomeTopSummaryCard(
                    bannerTheme: theme,
                    compact: compact,
                    nextText: nextText,
                    loadingReminders: loadingReminders,
                    reminderCount: reminderCount,
                  ),
                  SizedBox(height: compact ? 10 : 12),
                  compact
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: pills,
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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

class _HomeTopSummaryCard extends StatelessWidget {
  const _HomeTopSummaryCard({
    required this.bannerTheme,
    required this.compact,
    required this.nextText,
    required this.loadingReminders,
    required this.reminderCount,
  });

  final SoftBannerTheme bannerTheme;
  final bool compact;
  final String nextText;
  final bool loadingReminders;
  final int reminderCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = loadingReminders
        ? (l10n?.homeSummaryTitleLoading ?? '正在整理提醒')
        : reminderCount == 0
        ? (l10n?.homeSummaryTitleNone ?? '今日状态')
        : (l10n?.homeSummaryTitleNext ?? '下一条提醒');
    final detail = loadingReminders
        ? (l10n?.homeSummaryDetailLoading ?? '正在同步今天的提醒安排，请稍等一下')
        : reminderCount == 0
        ? (l10n?.homeSummaryDetailNone ?? '今天暂无待完成提醒，可以安心继续当前节奏')
        : nextText;
    final badgeText = loadingReminders
        ? (l10n?.homeSummaryBadgeLoading ?? '同步中')
        : reminderCount == 0
        ? (l10n?.homeSummaryBadgeRelaxed ?? '轻松日')
        : (l10n?.homeSummaryBadgeCount(reminderCount) ?? '$reminderCount 条安排');
    final icon = loadingReminders
        ? Icons.sync_rounded
        : reminderCount == 0
        ? Icons.done_all_rounded
        : Icons.alarm_rounded;

    return Container(
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 13,
        compact ? 10 : 12,
        compact ? 10 : 13,
        compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: bannerTheme.surfaceColor.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.78 : 0.55,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: bannerTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 34 : 36,
            height: compact ? 34 : 36,
            decoration: BoxDecoration(
              color: bannerTheme.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: compact ? 17 : 19,
              color: bannerTheme.accentColor,
            ),
          ),
          SizedBox(width: compact ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: bannerTheme.textColor,
                        fontSize: compact ? 13 : 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: bannerTheme.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: bannerTheme.accentColor,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: bannerTheme.secondaryTextColor,
                    fontSize: compact ? 12.5 : 13.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final titleColor = scheme.onSurface;
    final subtitleColor = scheme.onSurfaceVariant;
    final idleTint = Color.lerp(scheme.primary, scheme.secondary, 0.34)!;
    final doneTint = Color.lerp(scheme.tertiary, scheme.primary, 0.45)!;
    final idleBackground = appTintedSurface(
      context,
      idleTint,
      lightAlpha: 0.11,
      darkAlpha: 0.19,
    );
    final idleBorder = appTintedBorder(
      context,
      idleTint,
      lightAlpha: 0.22,
      darkAlpha: 0.33,
    );
    final doneBackground = appTintedSurface(
      context,
      doneTint,
      lightAlpha: 0.12,
      darkAlpha: 0.20,
    );
    final doneBorder = appTintedBorder(
      context,
      doneTint,
      lightAlpha: 0.23,
      darkAlpha: 0.35,
    );
    final idleIconTint = Color.lerp(
      const Color(0xFF0284C7),
      scheme.primary,
      0.45,
    )!;
    final doneIconTint = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.40,
    )!;
    final idleIconBackground = appTintedSurface(
      context,
      idleIconTint,
      lightAlpha: 0.19,
      darkAlpha: 0.28,
    );
    final doneIconBackground = appTintedSurface(
      context,
      doneIconTint,
      lightAlpha: 0.20,
      darkAlpha: 0.29,
    );
    final idleIconColor = Color.lerp(
      const Color(0xFF0284C7),
      scheme.primary,
      0.28,
    )!;
    final doneIconColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.30,
    )!;
    final statusIdleColor = Color.lerp(
      const Color(0xFFF59E0B),
      scheme.secondary,
      0.24,
    )!;
    final statusDoneColor = Color.lerp(
      const Color(0xFF16A34A),
      scheme.tertiary,
      0.30,
    )!;
    final subtitleText = item.subtitle.trim().isNotEmpty
        ? item.subtitle.trim()
        : item.dosage.trim().isNotEmpty
        ? '剂量: ${item.dosage.trim()}'
        : '-';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 7 : 10,
      ),
      decoration: BoxDecoration(
        color: item.done ? doneBackground : idleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.done ? doneBorder : idleBorder),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            decoration: BoxDecoration(
              color: item.done ? doneIconBackground : idleIconBackground,
              borderRadius: BorderRadius.circular(compact ? 8 : 9),
            ),
            child: Icon(
              item.icon,
              color: item.done ? doneIconColor : idleIconColor,
              size: compact ? 16 : 18,
            ),
          ),
          SizedBox(width: compact ? 7 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: compact ? 13.2 : 14,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: compact ? 1.5 : 2),
                Text(
                  subtitleText,
                  style: TextStyle(
                    fontSize: compact ? 11.2 : 12,
                    color: subtitleColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: item.done ? statusDoneColor : statusIdleColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

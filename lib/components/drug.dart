import 'package:flutter/material.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/responsive_quick_grid.dart';
import 'package:luminous/components/shared_quick_entry_card.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/drug.dart';

/// 药品页（Drug）的大块 UI 组件集合。
///
/// 页面层只负责加载“我的药品”数据、删除和跳转；
/// 具体分区布局（搜索入口、快捷入口、列表占位等）在这里统一管理。
class DrugPage extends StatelessWidget {
  /// 创建药品页主视图组件。
  const DrugPage({
    super.key,
    required this.quickEntries,
    required this.myMedicines,
    required this.loadingMedicines,
    required this.onRefresh,
    required this.onTapSearch,
    required this.onTapQuickEntry,
    required this.onTapMedicineRow,
    required this.onDeleteMedicine,
  });

  /// 快捷入口列表。
  final List<DrugQuickEntry> quickEntries;

  /// “我的药品”原始行数据列表。
  final List<Map<String, dynamic>> myMedicines;

  /// 当前是否正在加载药品列表。
  final bool loadingMedicines;

  /// 下拉刷新回调。
  final Future<void> Function() onRefresh;

  /// 点击搜索入口回调。
  final VoidCallback onTapSearch;

  /// 点击快捷入口回调。
  final ValueChanged<DrugQuickEntry> onTapQuickEntry;

  /// 点击药品行回调。
  final ValueChanged<Map<String, dynamic>> onTapMedicineRow;

  /// 点击删除药品回调。
  final ValueChanged<Map<String, dynamic>> onDeleteMedicine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            DrugSearchEntrySliver(onTap: onTapSearch),
            DrugQuickEntrySectionSliver(
              entries: quickEntries,
              onTapEntry: onTapQuickEntry,
            ),
            DrugMyMedicinesHeaderSliver(
              count: myMedicines.length,
              loading: loadingMedicines,
            ),
            if (loadingMedicines && myMedicines.isEmpty)
              const DrugLoadingSliver()
            else if (myMedicines.isEmpty)
              const DrugEmptyMedicinesSliver()
            else
              DrugMyMedicinesListSliver(
                rows: myMedicines,
                onDeleteMedicine: onDeleteMedicine,
                onTapRow: onTapMedicineRow,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

/// 药品页顶部搜索入口 sliver。
class DrugSearchEntrySliver extends StatelessWidget {
  const DrugSearchEntrySliver({super.key, required this.onTap});

  /// 点击搜索入口回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final searchIconColor = Color.lerp(
      const Color(0xFF0EA5E9),
      scheme.primary,
      0.42,
    )!;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = isCompactLayoutWidth(constraints.maxWidth);
            final iconBoxSize = compact ? 36.0 : 40.0;
            final cardPadding = compact ? 12.0 : 14.0;

            return AppSectionCard(
              accentColor: Color.lerp(scheme.primary, scheme.secondary, 0.35)!,
              secondaryColor: Color.lerp(
                scheme.secondary,
                scheme.tertiary,
                0.45,
              )!,
              ornamentKey: 'drug.search-entry',
              padding: EdgeInsets.zero,
              radius: 18,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Row(
                      children: [
                        Container(
                          width: iconBoxSize,
                          height: iconBoxSize,
                          decoration: BoxDecoration(
                            color: appTintedSurface(
                              context,
                              searchIconColor,
                              lightAlpha: 0.21,
                              darkAlpha: 0.31,
                            ),
                            borderRadius: BorderRadius.circular(
                              compact ? 12 : 14,
                            ),
                            border: Border.all(
                              color: appTintedBorder(
                                context,
                                searchIconColor,
                                lightAlpha: 0.27,
                                darkAlpha: 0.41,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            color: searchIconColor,
                            size: compact ? 20 : 24,
                          ),
                        ),
                        SizedBox(width: compact ? 10 : 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.drugSearchEntryTitle ?? '搜索药品',
                                style: TextStyle(
                                  fontSize: compact ? 14.5 : 15,
                                  fontWeight: FontWeight.w800,
                                  color: titleColor,
                                ),
                              ),
                              SizedBox(height: compact ? 3 : 4),
                              Text(
                                l10n?.drugSearchEntrySubtitle ??
                                    '支持：产品名称 / 批准文号 / 生产单位',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: compact ? 12 : 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: subtitleColor,
                                  height: compact ? 1.3 : 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: isDark ? Color(0xFFCBD5E1) : Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 药品页“快捷入口”区域 sliver。
class DrugQuickEntrySectionSliver extends StatelessWidget {
  const DrugQuickEntrySectionSliver({
    super.key,
    required this.entries,
    required this.onTapEntry,
  });

  /// 快捷入口数据列表。
  final List<DrugQuickEntry> entries;

  /// 点击快捷入口回调。
  final ValueChanged<DrugQuickEntry> onTapEntry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = SoftBannerPalettes.drugOf(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
            final metrics = ResponsiveQuickGridMetrics.fromWidth(
              constraints.maxWidth,
              textScaleFactor: textScaleFactor,
            );

            return SoftBannerCard(
              palette: palette,
              ornamentKey: 'drug.quick-banner',
              padding: EdgeInsets.all(metrics.sectionPadding),
              borderRadius: BorderRadius.circular(18),
              builder: (context, theme) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.drugQuickSectionTitle ?? '快捷入口',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: theme.textColor,
                      ),
                    ),
                    SizedBox(height: metrics.isCompact ? 2 : 3),
                    Text(
                      l10n?.drugQuickSectionSubtitle ?? '把高频操作收在一块，页面会更轻更顺手',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: theme.secondaryTextColor,
                      ),
                    ),
                    SizedBox(height: metrics.isCompact ? 10 : 12),
                    ResponsiveQuickWrap(
                      metrics: metrics,
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final item = entries[index];
                        return SharedQuickEntryCard(
                          icon: item.icon,
                          title: item.title,
                          subtitle: item.subtitle,
                          color: item.color,
                          metrics: metrics,
                          onTap: () => onTapEntry(item),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// 药品页“我的药品”标题栏 sliver。
class DrugMyMedicinesHeaderSliver extends StatelessWidget {
  const DrugMyMedicinesHeaderSliver({
    super.key,
    required this.count,
    required this.loading,
  });

  /// 当前药品总数。
  final int count;

  /// 当前是否处于加载状态。
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = isCompactLayoutWidth(constraints.maxWidth);
            return Row(
              children: [
                Text(
                  l10n?.drugMyMedicinesTitle ?? '我的药品',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 7 : 8,
                    vertical: compact ? 2.5 : 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                ),
                const Spacer(),
                if (loading)
                  SizedBox(
                    width: compact ? 14 : 16,
                    height: compact ? 14 : 16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// “我的药品”加载中的占位 sliver。
class DrugLoadingSliver extends StatelessWidget {
  const DrugLoadingSliver({super.key});

  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}

/// “我的药品”为空时的占位 sliver。
class DrugEmptyMedicinesSliver extends StatelessWidget {
  const DrugEmptyMedicinesSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF64748B);
    final iconBackground = isDark
        ? const Color(0xFF183246)
        : const Color(0x1A0EA5E9);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = isCompactLayoutWidth(constraints.maxWidth);
            return AppSectionCard(
              accentColor: Color.lerp(scheme.primary, scheme.secondary, 0.3)!,
              secondaryColor: Color.lerp(
                scheme.tertiary,
                scheme.secondary,
                0.4,
              )!,
              ornamentKey: 'drug.empty',
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 18,
                compact ? 28 : 36,
                compact ? 16 : 18,
                compact ? 28 : 36,
              ),
              radius: 18,
              child: Column(
                children: [
                  SizedBox(
                    width: compact ? 52 : 56,
                    height: compact ? 52 : 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: iconBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medication_outlined,
                        size: compact ? 28 : 30,
                        color: const Color(0xFF0EA5E9),
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 14),
                  Text(
                    l10n?.drugEmptyTitle ?? '暂无药品',
                    style: TextStyle(
                      fontSize: compact ? 14.5 : 15,
                      fontWeight: FontWeight.w700,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 6),
                  Text(
                    l10n?.drugEmptySubtitle ?? '通过"手动搜索"或"药物识别"\n将药品添加到这里',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 12.5 : 13,
                      color: subtitleColor,
                      height: compact ? 1.45 : 1.55,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// “我的药品”列表 sliver。
///
/// 只负责把行数据渲染为一组 `DrugMyMedicineCard`。
class DrugMyMedicinesListSliver extends StatelessWidget {
  const DrugMyMedicinesListSliver({
    super.key,
    required this.rows,
    required this.onDeleteMedicine,
    required this.onTapRow,
  });

  /// 原始数据库行数据列表。
  final List<Map<String, dynamic>> rows;

  /// 删除药品回调。
  final ValueChanged<Map<String, dynamic>> onDeleteMedicine;

  /// 点击药品行回调。
  final ValueChanged<Map<String, dynamic>> onTapRow;

  @override
  Widget build(BuildContext context) {
    final compact = isCompactLayoutWidth(MediaQuery.sizeOf(context).width);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      sliver: SliverList.builder(
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == rows.length - 1 ? 0 : (compact ? 8 : 10),
            ),
            child: DrugMyMedicineCard(
              row: row,
              onDelete: () => onDeleteMedicine(row),
              onTap: () => onTapRow(row),
            ),
          );
        },
      ),
    );
  }
}

/// “我的药品”列表中的单个药品卡片组件。
///
/// 该组件只负责展示，点击/删除行为通过回调交由页面处理。
class DrugMyMedicineCard extends StatelessWidget {
  /// 创建一个药品卡片组件。
  const DrugMyMedicineCard({
    super.key,
    required this.row,
    required this.onDelete,
    required this.onTap,
  });

  /// 数据库行数据。
  final Map<String, dynamic> row;

  /// 点击删除按钮回调。
  final VoidCallback onDelete;

  /// 点击卡片回调。
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    /// 将原始行数据转换为 UI 渲染友好的展示模型。
    final item = DrugMedicineCardViewModel.fromRow(
      row,
      unknownProductName: l10n?.drugUnknownMedicineName ?? '未知药品',
      approvalNoLabel: l10n?.drugApprovalNoLabel ?? '批准文号',
      sourceScanLabel: l10n?.drugSourceScanLabel ?? '拍照识别',
      sourceManualSearchLabel: l10n?.drugSourceManualLabel ?? '手动搜索',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtitleColor = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF475569);
    final metaColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF94A3B8);
    final dateColor = isDark
        ? const Color(0xFF7F8DA3)
        : const Color(0xFFB0BAC8);

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = isCompactLayoutWidth(constraints.maxWidth);

          return AppSectionCard(
            radius: 16,
            padding: EdgeInsets.zero,
            accentColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.15),
            secondaryColor: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.15),
            baseColor: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: isDark ? 0.35 : 0.65),
            ornamentKey: 'drug.item',
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                  compact ? 10 : 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 40 : 44,
                      height: compact ? 40 : 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(compact ? 12 : 14),
                      ),
                      child: Icon(
                        Icons.medication_rounded,
                        color: const Color(0xFF0EA5E9),
                        size: compact ? 22 : 24,
                      ),
                    ),
                    SizedBox(width: compact ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: compact ? 14.5 : 15,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            SizedBox(height: compact ? 2 : 3),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: compact ? 12 : 12.5,
                                color: subtitleColor,
                              ),
                            ),
                          ],
                          if (item.metaText.isNotEmpty) ...[
                            SizedBox(height: compact ? 2 : 3),
                            Text(
                              item.metaText,
                              style: TextStyle(
                                fontSize: compact ? 11 : 11.5,
                                color: metaColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: compact ? 5 : 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (item.sourceLabel.isNotEmpty)
                                TintedStatusChip(
                                  text: item.sourceLabel,
                                  color: item.sourceColor,
                                  backgroundColor: item.sourceColor.withValues(
                                    alpha: 0.12,
                                  ),
                                  showBorder: false,
                                  fontSize: compact ? 10.5 : 11,
                                  fontWeight: FontWeight.w600,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: compact ? 6 : 7,
                                    vertical: compact ? 2.5 : 3,
                                  ),
                                ),
                              if (item.dateText.isNotEmpty)
                                Text(
                                  item.dateText,
                                  style: TextStyle(
                                    fontSize: compact ? 10.5 : 11,
                                    color: dateColor,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        width: compact ? 34 : 36,
                        height: compact ? 34 : 36,
                        margin: const EdgeInsets.only(left: 8),
                        alignment: Alignment.topCenter,
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: compact ? 22 : 24,
                          color: Colors.red.shade300,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

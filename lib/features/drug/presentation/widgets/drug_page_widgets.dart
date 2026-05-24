import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/features/drug/presentation/models/drug_models.dart';
import 'drug_quick_entry_section.dart';
import 'drug_my_medicines_widgets.dart';

/// 药品页（Drug）的大块 UI 组件集合。
///
/// 页面层只负责加载"我的药品"数据、删除和跳转；
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

  /// "我的药品"原始行数据列表。
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

import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/responsive_quick_grid.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';

import 'package:luminous/features/drug/presentation/models/drug_models.dart';

/// 药品页"我的药品"标题栏 sliver。
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

/// "我的药品"加载中的占位 sliver。
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

/// "我的药品"为空时的占位 sliver。
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

/// "我的药品"列表 sliver。
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

/// "我的药品"列表中的单个药品卡片组件。
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

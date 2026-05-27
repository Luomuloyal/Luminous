import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/medicine_picker_provider.dart';
import 'package:luminous/shared/models/medicine.dart';

/// 药品选择器页面。
///
/// 统一承接“从我的药品选择”与“跳转搜索库选择”两种入口，并把结果返回给上层页面。
class MedicinePickerPage extends ConsumerWidget {
  /// 创建药品选择器页面。
  const MedicinePickerPage({super.key, this.title});

  /// 顶部 AppBar 标题（可由上层覆盖）。
  final String? title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(medicinePickerProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = itemsAsync.hasValue
        ? itemsAsync.value!
        : const <MedicineItem>[];
    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(title ?? l10n?.drugPickerTitle ?? '选择药品'),
        centerTitle: true,
        foregroundColor: const Color(0xFF0F172A),
      ),
      appBarSpacing: 32,
      accentColor: scheme.primary,
      secondaryAccentColor: Color.lerp(scheme.secondary, scheme.tertiary, 0.5)!,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(medicinePickerProvider),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            _buildSearchEntry(context),
            const SizedBox(height: 12),
            _buildMyMedicinesCard(context, items, itemsAsync.isLoading),
          ],
        ),
      ),
    );
  }

  /// 构建顶部“手动搜索药品库”入口。
  Widget _buildSearchEntry(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppSectionCard(
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'picker.search-entry',
      padding: EdgeInsets.zero,
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openSearchPicker(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: appTintedSurface(
                      context,
                      scheme.primary,
                      lightAlpha: 0.10,
                      darkAlpha: 0.18,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.search_rounded, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: appTintedSurface(
                            context,
                            scheme.secondary,
                            lightAlpha: 0.09,
                            darkAlpha: 0.16,
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n?.pickerSearchBadge ?? '云端药品库',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: scheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.pickerSearchTitle ?? '手动搜索药品库',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.pickerSearchSubtitle ??
                            '从云端搜索后直接带回当前流程，适合本地还没保存时快速补查。',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建“我的药品”选择卡片区域。
  ///
  /// 用户可以直接从本地已添加的药品里点选，也可以跳到搜索页重新选择。
  Widget _buildMyMedicinesCard(
    BuildContext context,
    List<MedicineItem> items,
    bool loading,
  ) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AppSectionCard(
      accentColor: scheme.tertiary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'picker.my-medicines',
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n?.pickerMyMedicinesTitle ?? '我的药品',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              if (items.isNotEmpty)
                TintedStatusChip(
                  text:
                      l10n?.pickerCount(items.length) ?? '共 ${items.length} 项',
                  color: scheme.tertiary,
                  showBorder: false,
                  surfaceLightAlpha: 0.08,
                  surfaceDarkAlpha: 0.16,
                  fontSize: 11.3,
                  fontWeight: FontWeight.w700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                ),
              const Spacer(),
              if (loading) ...[
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n?.pickerSyncing ?? '同步中',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  scheme.tertiary,
                  lightAlpha: 0.045,
                  darkAlpha: 0.10,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: appTintedBorder(
                    context,
                    scheme.tertiary,
                    lightAlpha: 0.08,
                    darkAlpha: 0.18,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.tertiary,
                        lightAlpha: 0.09,
                        darkAlpha: 0.16,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.medication_liquid_rounded,
                      color: scheme.tertiary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n?.pickerEmptyTitle ?? '还没有本地药品记录',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.pickerEmptySubtitle ?? '你可以先去云端药品库补查，或者稍后再把常用药保存到这里。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            )
          else
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == items.length - 1 ? 0 : 10,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.pop(item),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.primary,
                        lightAlpha: 0.04,
                        darkAlpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: appTintedBorder(
                          context,
                          scheme.primary,
                          lightAlpha: 0.08,
                          darkAlpha: 0.18,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: appTintedSurface(
                              context,
                              scheme.primary,
                              lightAlpha: 0.10,
                              darkAlpha: 0.18,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.medication_rounded,
                            color: scheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.displayName,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TintedStatusChip(
                                    text: item.displayBadge,
                                    color: scheme.primary,
                                    showBorder: false,
                                    surfaceLightAlpha: 0.08,
                                    surfaceDarkAlpha: 0.16,
                                    fontSize: 10.8,
                                    fontWeight: FontWeight.w700,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.displaySubtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                              if (item.displayTips.isNotEmpty) ...[
                                const SizedBox(height: 7),
                                Text(
                                  item.displayTips,
                                  style: TextStyle(
                                    fontSize: 11.8,
                                    color: scheme.onSurfaceVariant.withValues(
                                      alpha: 0.88,
                                    ),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: scheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  /// 打开搜索页进行药品选择。
  ///
  /// 搜索页会以 `pickerMode=true` 打开，选中后直接返回 `MedicineItem`。
  Future<void> _openSearchPicker(BuildContext context) async {
    /// 从搜索页返回的药品对象。
    final result = await context.push<MedicineItem>(
      '/search',
      extra: <String, dynamic>{'pickerMode': true},
    );
    if (result == null || !context.mounted) return;
    context.pop(result);
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/pages/Mine/controllers/browse_history_controller.dart';
import 'package:luminous/viewmodels/browse_history.dart';

/// 浏览记录页。
///
/// 展示本机最近查看过的药品详情，并支持再次打开、删除与清空。
class BrowseHistoryPage extends StatelessWidget {
  const BrowseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BrowseHistoryController>(
      init: BrowseHistoryController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        return AppCanvasPageScaffold(
          appBar: AppBar(
            title: Text(l10n?.mineBrowseHistoryPageTitle ?? '浏览记录'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                onPressed: controller.loading || controller.busy
                    ? null
                    : controller.load,
                icon: controller.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
              IconButton(
                onPressed: controller.items.isEmpty || controller.busy
                    ? null
                    : () => _confirmClearAll(context, controller),
                icon: const Icon(Icons.delete_sweep_rounded),
                tooltip:
                    l10n?.mineBrowseHistoryClearAction ??
                    l10n?.searchHistoryClearAction ??
                    '清空',
              ),
            ],
          ),
          appBarSpacing: 30,
          accentColor: scheme.secondary,
          secondaryAccentColor: Color.lerp(
            scheme.primary,
            scheme.tertiary,
            0.48,
          )!,
          child: RefreshIndicator(
            onRefresh: controller.load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              children: [
                _HistoryHeroCard(controller: controller),
                const SizedBox(height: 10),
                if (controller.items.isEmpty && !controller.loading)
                  _EmptyStateCard(
                    onTapSearch: () => Navigator.pushNamed(context, '/search'),
                  )
                else
                  ...controller.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == controller.items.length - 1 ? 0 : 8,
                      ),
                      child: _HistoryItemCard(
                        entry: item,
                        busy: controller.busy,
                        onTap: () => _openDetail(context, item),
                        onRemove: () => controller.remove(item),
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    BrowseHistoryController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n?.mineBrowseHistoryClearConfirmTitle ?? '清空浏览记录'),
          content: Text(
            l10n?.mineBrowseHistoryClearConfirmMessage ??
                '清空后将删除当前账号下的本机浏览记录，且无法恢复。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n?.reminderDeleteCancel ?? '取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n?.mineBrowseHistoryConfirmAction ??
                    l10n?.searchHistoryClearAction ??
                    '清空',
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await controller.clearAll();
    }
  }

  void _openDetail(BuildContext context, BrowseHistoryEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MedicineDetailPage(initialItem: entry.toMedicineItem()),
      ),
    );
  }
}

class _HistoryHeroCard extends StatelessWidget {
  const _HistoryHeroCard({required this.controller});

  final BrowseHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: Color.lerp(scheme.secondary, scheme.primary, 0.35)!,
      secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.4)!,
      ornamentKey: 'mine.browse-history.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.mineBrowseHistoryHeroTitle ?? '最近查看',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.mineBrowseHistoryHeroSubtitle ?? '进入药品详情后会自动记录，方便稍后继续查看。',
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.history_rounded,
                text:
                    l10n?.mineBrowseHistoryCountLabel(controller.count) ??
                    '${controller.count} 条记录',
                color: scheme.secondary,
              ),
              TintedStatusChip(
                icon: controller.isLoggedIn
                    ? Icons.person_rounded
                    : Icons.phone_android_rounded,
                text: controller.isLoggedIn
                    ? (l10n?.mineBrowseHistoryScopeAccount ?? '当前账号')
                    : (l10n?.mineBrowseHistoryScopeGuest ?? '本机游客记录'),
                color: Color.lerp(scheme.primary, scheme.tertiary, 0.34)!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.onTapSearch});

  final VoidCallback onTapSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.secondary, scheme.primary, 0.42)!;
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.42)!,
      ornamentKey: 'mine.browse-history.empty',
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      radius: 18,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTintedSurface(
                context,
                accent,
                lightAlpha: 0.12,
                darkAlpha: 0.20,
              ),
              border: Border.all(
                color: appTintedBorder(
                  context,
                  accent,
                  lightAlpha: 0.18,
                  darkAlpha: 0.26,
                ),
              ),
            ),
            child: Icon(
              Icons.history_toggle_off_rounded,
              color: accent,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n?.mineBrowseHistoryEmptyTitle ?? '还没有浏览记录',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n?.mineBrowseHistoryEmptySubtitle ?? '去搜索或识别药品，打开详情后就会自动出现在这里。',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.8,
              height: 1.5,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: onTapSearch,
            icon: const Icon(Icons.search_rounded),
            label: Text(l10n?.mineBrowseHistoryOpenSearchAction ?? '去搜索药品'),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.entry,
    required this.busy,
    required this.onTap,
    required this.onRemove,
  });

  final BrowseHistoryEntry entry;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final accent = Color.lerp(scheme.secondary, scheme.primary, 0.42)!;
    final secondary = Color.lerp(scheme.tertiary, scheme.secondary, 0.36)!;
    final tips = entry.displayTips;
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: secondary,
      ornamentKey: _historyItemOrnamentKey(entry.identityKey),
      ornamentVisibilityScale: 0.22,
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      radius: 16,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  accent,
                  lightAlpha: 0.10,
                  darkAlpha: 0.18,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.medication_rounded, color: accent, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.displayTitle,
                            style: TextStyle(
                              fontSize: 14.6,
                              fontWeight: FontWeight.w800,
                              color: scheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatHistoryTimeLabel(context, entry.viewedAt),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      entry.displaySubtitle,
                      style: TextStyle(
                        fontSize: 12.4,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tips.isNotEmpty
                          ? tips
                          : (entry.approvalNo.isNotEmpty
                                ? (l10n?.searchApprovalNoPrefix(
                                        entry.approvalNo,
                                      ) ??
                                      '批准文号: ${entry.approvalNo}')
                                : entry.drugCode),
                      style: TextStyle(
                        fontSize: 11.8,
                        fontWeight: FontWeight.w600,
                        color: Color.lerp(
                          scheme.onSurfaceVariant,
                          scheme.onSurface,
                          0.12,
                        ),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              IconButton(
                onPressed: busy ? null : onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: l10n?.mineBrowseHistoryRemoveAction ?? '移除',
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(height: 2),
              Icon(
                Icons.chevron_right_rounded,
                color: accent.withValues(alpha: 0.78),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _historyItemOrnamentKey(String identityKey) {
  final sanitized = identityKey.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  if (sanitized.isEmpty) {
    return 'mine.browse-history.item.unknown';
  }
  return 'mine.browse-history.item.$sanitized';
}

String _formatHistoryTimeLabel(BuildContext context, DateTime value) {
  if (value.millisecondsSinceEpoch <= 0) {
    return '';
  }

  final l10n = AppLocalizations.of(context);
  final now = DateTime.now();
  final day = DateTime(value.year, value.month, value.day);
  final today = DateTime(now.year, now.month, now.day);
  final delta = today.difference(day).inDays;
  if (delta == 0) {
    return l10n?.homeCheckInRecordsToday ?? 'Today';
  }
  if (delta == 1) {
    return l10n?.homeCheckInRecordsYesterday ?? 'Yesterday';
  }
  final month = value.month.toString().padLeft(2, '0');
  final dayText = value.day.toString().padLeft(2, '0');
  if (value.year == now.year) {
    return '$month/$dayText';
  }
  return '${value.year}-$month-$dayText';
}

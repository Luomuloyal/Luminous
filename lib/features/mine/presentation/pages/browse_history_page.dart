import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/drug/presentation/drug.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/mine/presentation/models/browse_history.dart';

import '../providers/mine_provider.dart';

/// 浏览记录页。
class BrowseHistoryPage extends ConsumerWidget {
  const BrowseHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(browseHistoryProvider);
    final isLoggedIn = ref.watch(
      currentUserProvider.select((u) => u?.hasData ?? false),
    );
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final items = entriesAsync.hasValue ? entriesAsync.value! : const <BrowseHistoryEntry>[];
    final loading = entriesAsync.isLoading;

    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(l10n?.mineBrowseHistoryPageTitle ?? '浏览记录'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed: loading ? null : () => ref.invalidate(browseHistoryProvider),
            icon: loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: items.isEmpty
                ? null
                : () => _confirmClearAll(context, ref),
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: l10n?.mineBrowseHistoryClearAction ?? '清空',
          ),
        ],
      ),
      appBarSpacing: 30,
      accentColor: scheme.secondary,
      secondaryAccentColor: Color.lerp(scheme.primary, scheme.tertiary, 0.48)!,
      child: RefreshIndicator(
        onRefresh: () async => ref.invalidate(browseHistoryProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
          children: [
            _HistoryHeroCard(items: items, isLoggedIn: isLoggedIn),
            const SizedBox(height: 10),
            if (items.isEmpty && !loading)
              _EmptyStateCard(
                onTapSearch: () => Navigator.pushNamed(context, '/search'),
              )
            else
              ...items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 8),
                  child: _HistoryItemCard(
                    entry: item,
                    busy: false,
                    onTap: () => _openDetail(context, item),
                    onRemove: () => ref.read(browseHistoryProvider.notifier).remove(item),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n?.mineBrowseHistoryClearConfirmTitle ?? '清空浏览记录'),
          content: Text(
            l10n?.mineBrowseHistoryClearConfirmMessage ?? '清空后将删除当前账号下的本机浏览记录，且无法恢复。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n?.reminderDeleteCancel ?? '取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n?.mineBrowseHistoryConfirmAction ?? '清空'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await ref.read(browseHistoryProvider.notifier).clearAll();
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
  const _HistoryHeroCard({required this.items, required this.isLoggedIn});

  final List<BrowseHistoryEntry> items;
  final bool isLoggedIn;

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
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: scheme.onSurface),
          ),
          const SizedBox(height: 4),
          Text(
            l10n?.mineBrowseHistoryHeroSubtitle ?? '进入药品详情后会自动记录，方便稍后继续查看。',
            style: TextStyle(fontSize: 12.8, height: 1.45, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.history_rounded,
                text: l10n?.mineBrowseHistoryCountLabel(items.length) ?? '${items.length} 条记录',
                color: scheme.secondary,
              ),
              TintedStatusChip(
                icon: isLoggedIn ? Icons.person_rounded : Icons.phone_android_rounded,
                text: isLoggedIn ? (l10n?.mineBrowseHistoryScopeAccount ?? '当前账号') : (l10n?.mineBrowseHistoryScopeGuest ?? '本机游客记录'),
                color: isLoggedIn ? scheme.primary : scheme.tertiary,
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
    return Center(
      child: AppSectionCard(
        accentColor: Color.lerp(scheme.tertiary, scheme.secondary, 0.35)!,
        secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.4)!,
        ornamentKey: 'mine.browse-history.empty',
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        radius: 18,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history_rounded, size: 42, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            Text(l10n?.mineBrowseHistoryEmptyTitle ?? '暂无浏览记录', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: scheme.onSurface)),
            const SizedBox(height: 6),
            Text(l10n?.mineBrowseHistoryEmptySubtitle ?? '查看药品详情后会记录在这里', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onTapSearch,
              icon: const Icon(Icons.search),
              label: const Text('去搜索'),
              style: FilledButton.styleFrom(minimumSize: const Size(120, 40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({required this.entry, required this.busy, required this.onTap, required this.onRemove});
  final BrowseHistoryEntry entry;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppSectionCard(
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'mine.browse-history.item',
      padding: EdgeInsets.zero,
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(color: scheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                  child: Icon(Icons.medication_outlined, color: scheme.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.displayTitle, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: scheme.onSurface)),
                      if (entry.displaySubtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(entry.displaySubtitle, style: TextStyle(fontSize: 12.2, height: 1.4, color: scheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      ],
                    ],
                  ),
                ),
                IconButton(onPressed: busy ? null : onRemove, icon: const Icon(Icons.close_rounded, size: 20), color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

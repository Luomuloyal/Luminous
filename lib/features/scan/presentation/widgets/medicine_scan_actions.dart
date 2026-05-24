part of '../scan.dart';

extension _MedicineScanActions on _MedicineScanPageState {
  Widget _buildActionsSection(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final selected = controller.selectedCandidate;
    final hasResult = selected != null;
    final searchKeyword = controller.searchKeyword;

    return Column(
      children: [
        _ActionTile(
          icon: Icons.refresh_rounded,
          color: const Color(0xFF0EA5E9),
          label: _actionRescanLabel(l10n),
          subtitle: _actionRescanSubtitle(l10n),
          onTap: controller.scanning
              ? null
              : () => controller.pickAndScan(
                  pickImage: () => pickMedicineScanImage(context),
                ),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.photo_library_outlined,
          color: const Color(0xFF6366F1),
          label: _actionSaveAlbumLabel(l10n),
          subtitle: _actionSaveAlbumSubtitle(l10n, controller.savingToAlbum),
          onTap: hasResult && controller.canSaveToAlbum
              ? controller.saveToAppAlbum
              : null,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.search_rounded,
          color: const Color(0xFF10B981),
          label: _actionSearchLabel(l10n),
          subtitle: _actionSearchSubtitle(l10n, searchKeyword.isNotEmpty),
          onTap: searchKeyword.isEmpty
              ? null
              : () => _searchSelectedMedicine(controller),
        ),
        const SizedBox(height: 10),
        _ActionTile(
          icon: Icons.close_rounded,
          color: const Color(0xFF94A3B8),
          label: _actionCancelLabel(l10n),
          subtitle: _actionCancelSubtitle(l10n),
          onTap: controller.scanning ? null : () => Navigator.maybePop(context),
        ),
      ],
    );
  }

  Future<void> _searchSelectedMedicine(
    MedicineScanController controller,
  ) async {
    final l10n = AppLocalizations.of(context);
    final keyword = controller.searchKeyword;
    if (keyword.isEmpty) {
      ToastUtils.instance.show(context, _searchMissingKeywordToastText(l10n));
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SearchPage(initialKeyword: keyword, autoSearchOnInit: true),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AppSurfaceCard(
        radius: 16,
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
                    color,
                    lightAlpha: 0.10,
                    darkAlpha: 0.18,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                onTap == null
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

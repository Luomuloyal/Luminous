part of '../scan.dart';

extension _MedicineScanSheet on _MedicineScanPageState {
  Widget _buildSheet(
    ScrollController scrollController,
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: scheme.outline.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildHeaderRow(controller, l10n),
          const SizedBox(height: 12),
          if (controller.lastError != null)
            _buildErrorCard(controller.lastError!),
          _buildResultSection(controller, l10n),
          const SizedBox(height: 10),
          _buildActionsSection(controller, l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
    MedicineScanController controller,
    AppLocalizations? l10n,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final title = _pageTitle(l10n);
    final subtitle = _headerSubtitle(l10n, controller);

    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: appTintedSurface(
              context,
              const Color(0xFF10B981),
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.camera_alt_outlined,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: controller.scanning
              ? null
              : () => controller.pickAndScan(
                  pickImage: () => pickMedicineScanImage(context),
                ),
          icon: const Icon(Icons.camera_alt_rounded, size: 16),
          label: Text(l10n?.scanRetakeAction ?? 'Retake'),
        ),
      ],
    );
  }

  Widget _buildErrorCard(String message) {
    final scheme = Theme.of(context).colorScheme;
    return AppSurfaceCard(
      radius: 16,
      borderColor: appTintedBorder(
        context,
        const Color(0xFFEF4444),
        lightAlpha: 0.16,
        darkAlpha: 0.24,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: appTintedSurface(
                  context,
                  const Color(0xFFEF4444),
                  lightAlpha: 0.12,
                  darkAlpha: 0.20,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

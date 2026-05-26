part of '../scan.dart';

extension _MedicineScanResultSection on _MedicineScanPageState {
  Widget _buildResultSection(
    ScanState state,
    AppLocalizations? l10n,
  ) {
    final result = state.scanResult;
    final scheme = Theme.of(context).colorScheme;
    if (state.scanning) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (result == null) {
      return _buildInfoCard(_infoNoResultText(l10n));
    }

    if (result.candidates.isEmpty) {
      return _buildInfoCard(_infoNoCandidateText(l10n));
    }

    return AppSurfaceCard(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _resultSectionTitle(l10n),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            ...result.candidates.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              final selected = index == state.selectedIndex;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == result.candidates.length - 1 ? 0 : 10,
                ),
                child: InkWell(
                  onTap: () => ref.read(scanProvider.notifier).selectCandidate(index),
                  borderRadius: BorderRadius.circular(14),
                  child: Ink(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: appTintedSurface(
                        context,
                        scheme.primary,
                        lightAlpha: selected ? 0.08 : 0.03,
                        darkAlpha: selected ? 0.15 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? appTintedBorder(
                                context,
                                scheme.primary,
                                lightAlpha: 0.16,
                                darkAlpha: 0.24,
                              )
                            : scheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.displayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.displaySubtitle,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c.manufacturer.trim().isEmpty
                                    ? (c.approvalNo.trim().isEmpty
                                          ? ''
                                          : _approvalNoText(l10n, c.approvalNo))
                                    : c.manufacturer,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (c.score > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: appTintedSurface(
                                context,
                                const Color(0xFF10B981),
                                lightAlpha: 0.10,
                                darkAlpha: 0.18,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${(c.score * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return AppSurfaceCard(
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

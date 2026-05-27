import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../providers/safety_provider.dart';
import '../widgets/safety_assist_widgets.dart';
import '../support/safety_assist_text.dart';

/// 安全辅助药品选择卡片。
class SafetyPickCard extends ConsumerWidget {
  const SafetyPickCard({
    super.key,
    required this.onPickMedicine,
  });

  final Future<void> Function({required int slot}) onPickMedicine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final tileAColor = scheme.primary;
    final tileBColor = Color.lerp(scheme.secondary, scheme.tertiary, 0.35)!;
    return SafetySectionCard(
      title: l10n?.safetyPickCardTitle ?? 'Select Medicines',
      accentColor: scheme.primary,
      secondaryColor: scheme.secondary,
      ornamentKey: 'safety.pick',
      child: Column(
        children: [
          _pickTile(
            context: context,
            label:
                state.medicineA?.displayName ??
                pickPlaceholderText(l10n, 0),
            subtitle:
                state.medicineA?.displaySubtitle ??
                pickSubtitleText(l10n),
            color: tileAColor,
            onTap: () => onPickMedicine(slot: 0),
            badge: pickBadgeText(l10n, 0),
            note: state.medicineA?.displayTips,
          ),
          if (state.mode == 'pair') ...[
            const SizedBox(height: 8),
            _pickTile(
              context: context,
              label:
                  state.medicineB?.displayName ??
                  pickPlaceholderText(l10n, 1),
              subtitle:
                  state.medicineB?.displaySubtitle ??
                  pickSubtitleText(l10n),
              color: tileBColor,
              onTap: () => onPickMedicine(slot: 1),
              badge: pickBadgeText(l10n, 1),
              note: state.medicineB?.displayTips,
            ),
          ],
        ],
      ),
    );
  }

  Widget _pickTile({
    required BuildContext context,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required String badge,
    String? note,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.small),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: appTintedSurface(
            context,
            color,
            lightAlpha: 0.05,
            darkAlpha: 0.11,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
          border: Border.all(
            color: appTintedBorder(
              context,
              color,
              lightAlpha: 0.10,
              darkAlpha: 0.18,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(Icons.medication_outlined, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: AppTypography.cardTitle,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TintedStatusChip(
                        text: badge,
                        color: color,
                        enablePopup: false,
                        showBorder: false,
                        fontSize: 10.2,
                        fontWeight: FontWeight.w700,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                  if (note != null && note.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      note.trim(),
                      style: TextStyle(
                        fontSize: 11.2,
                        color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

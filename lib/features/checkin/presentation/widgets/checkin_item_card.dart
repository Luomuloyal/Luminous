import 'package:flutter/material.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/models/home.dart';

/// 打卡项卡片。
class CheckInItemCard extends StatelessWidget {
  const CheckInItemCard({
    super.key,
    required this.item,
    required this.onCheckIn,
  });

  final ReminderItem item;
  final VoidCallback onCheckIn;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final done = item.done;
    final accent = done ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return AppSectionCard(
      accentColor: accent,
      secondaryColor: Color.lerp(accent, scheme.primary, 0.35)!,
      ornamentKey: 'checkin.card.item',
      radius: 18,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.chip),
            ),
            child: Icon(Icons.access_time_rounded, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title.trim().isNotEmpty
                            ? item.title.trim()
                            : '用药提醒',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    if (item.time.trim().isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        item.time.trim(),
                        style: TextStyle(
                          fontSize: AppTypography.cardMeta,
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                if (item.subtitle.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle.trim(),
                    style: TextStyle(
                      fontSize: AppTypography.cardMeta,
                      height: 1.4,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (item.dosage.trim().isNotEmpty)
                  Text(
                    item.dosage.trim(),
                    style: TextStyle(
                      fontSize: AppTypography.cardMeta,
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onCheckIn,
            style: FilledButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              minimumSize: const Size(72, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: Text(done ? '取消打卡' : '打卡'),
          ),
        ],
      ),
    );
  }
}

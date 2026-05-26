import 'package:flutter/material.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/shared/widgets/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/home.dart';

/// 打卡页 Hero 统计卡片。
class CheckInHeroCard extends StatelessWidget {
  const CheckInHeroCard({super.key, required this.items});

  final List<ReminderItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final locale = (l10n?.localeName ?? 'zh').toLowerCase();
    final subtitleText = locale.startsWith('zh')
        ? '到点打卡，帮助你连续跟踪每日用药完成情况'
        : 'Check in on time to track your daily medication completion.';
    final doneCount = items.where((i) => i.done).length;
    final pendingCount = items.length - doneCount;

    return AppSectionCard(
      accentColor: const Color(0xFFF59E0B),
      secondaryColor: const Color(0xFF38BDF8),
      ornamentKey: 'checkin.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.checkInPageTitle ?? '用药打卡',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitleText,
            style: TextStyle(
              fontSize: 12.8,
              height: 1.45,
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              TintedStatusChip(
                icon: Icons.library_books_rounded,
                text: '${items.length} 条',
                color: const Color(0xFF0EA5E9),
              ),
              TintedStatusChip(
                icon: Icons.check_circle_rounded,
                text: '$doneCount 已打卡',
                color: const Color(0xFF10B981),
              ),
              TintedStatusChip(
                icon: Icons.alarm_rounded,
                text: '$pendingCount 待完成',
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

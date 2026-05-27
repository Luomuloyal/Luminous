import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/soft_banner/soft_banner.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../providers/safety_provider.dart';
import '../widgets/safety_assist_widgets.dart';
import '../support/safety_assist_text.dart';

/// 安全辅助 Hero 卡片。
class SafetyHeroCard extends ConsumerWidget {
  const SafetyHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final loggedIn = ref.read(currentUserProvider)?.hasData == true;

    return SoftBannerCard(
      palette: SoftBannerPalettes.drugOf(context),
      ornamentKey: 'safety.hero',
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      builder: (context, theme) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.surfaceColor,
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    color: theme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        safetyTitle(l10n),
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 17.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        heroSubtitle(l10n),
                        style: TextStyle(
                          color: theme.secondaryTextColor,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SafetyInfoChip(
                    icon: state.mode == 'pair'
                        ? Icons.compare_arrows_rounded
                        : Icons.auto_awesome_rounded,
                    text: state.mode == 'pair'
                        ? modePairText(l10n)
                        : modeSingleText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: SafetyInfoChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_outlined,
                    text: loggedIn
                        ? cloudWithContextText(l10n)
                        : cloudQueryText(l10n),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

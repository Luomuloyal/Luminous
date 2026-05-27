import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/design_tokens/design_tokens.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../providers/safety_provider.dart';
import '../widgets/safety_assist_widgets.dart';
import '../support/safety_assist_text.dart';

/// 安全辅助操作卡片（查询/取消按钮）。
class SafetyActionCard extends ConsumerWidget {
  const SafetyActionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafetySectionCard(
      title: l10n?.safetyActionCardTitle ?? 'Start Query',
      accentColor: scheme.tertiary,
      secondaryColor: scheme.primary,
      ornamentKey: 'safety.action',
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: state.loading || !state.ready
                  ? null
                  : () => ref.read(safetyProvider.notifier).query(
                      refresh: state.result != null,
                    ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
              ),
              child: state.loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: scheme.onPrimary,
                      ),
                    )
                  : Text(
                      actionQueryText(
                        l10n,
                        state.mode,
                        hasResult: state.result != null,
                      ),
                    ),
            ),
          ),
          if (state.loading) ...[
            const SizedBox(width: 6),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(safetyProvider.notifier).cancelQuery(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(78, 44),
                backgroundColor: const Color(
                  0xFFEF4444,
                ).withValues(alpha: 0.12),
                foregroundColor: const Color(0xFFB91C1C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  side: const BorderSide(color: Color(0xFFEF4444)),
                ),
              ),
              child: Text(cancelActionText(l10n)),
            ),
          ],
        ],
      ),
    );
  }
}

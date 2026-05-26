import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/l10n/app_localizations.dart';

import '../providers/safety_provider.dart';
import 'safety_assist_widgets.dart';

/// 安全辅助模式切换卡片。
class SafetyModeCard extends ConsumerWidget {
  const SafetyModeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return SafetySectionCard(
      title: l10n?.safetyModeCardTitle ?? 'Query Mode',
      accentColor: scheme.secondary,
      secondaryColor: scheme.tertiary,
      ornamentKey: 'safety.mode',
      child: SafetyModeSwitcher(
        mode: state.mode,
        l10n: l10n,
        onSelectSingle: () =>
            ref.read(safetyProvider.notifier).setMode('single'),
        onSelectPair: () =>
            ref.read(safetyProvider.notifier).setMode('pair'),
      ),
    );
  }
}

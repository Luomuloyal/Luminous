import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/shared/models/medicine.dart';

import '../providers/safety_provider.dart';
import '../widgets/safety_assist_widgets.dart';
import '../widgets/safety_hero_card.dart';
import '../widgets/safety_mode_card.dart';
import '../widgets/safety_pick_card.dart';
import '../widgets/safety_action_card.dart';
import '../support/safety_assist_text.dart';

/// 安全辅助页。
///
/// 页面允许用户选择一款或两款药品，并调用 AI 接口生成用药建议或相互作用提示。
class SafetyAssistPage extends ConsumerWidget {
  /// 创建安全辅助页组件。
  const SafetyAssistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetyProvider);
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final secondaryAccent = Color.lerp(
      scheme.secondary,
      scheme.tertiary,
      0.52,
    )!;
    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(safetyTitle(l10n)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      appBarSpacing: 20,
      accentColor: scheme.primary,
      secondaryAccentColor: secondaryAccent,
      child: RefreshIndicator(
        onRefresh: () => ref.read(safetyProvider.notifier).refreshResult(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 18),
          children: [
            const SafetyHeroCard(),
            const SizedBox(height: 8),
            const SafetyModeCard(),
            const SizedBox(height: 8),
            SafetyPickCard(
              onPickMedicine: ({required int slot}) =>
                  _pickMedicine(context, ref, slot: slot),
            ),
            const SizedBox(height: 8),
            const SafetyActionCard(),
            const SizedBox(height: 8),
            SafetyResultSection(result: state.result, l10n: l10n),
            const SizedBox(height: 8),
            const SafetyDisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedicine(
    BuildContext context,
    WidgetRef ref, {
    required int slot,
  }) async {
    final l10n = AppLocalizations.of(context);
    final item = await context.push<MedicineItem>(
      '/medicine-picker',
      extra: <String, dynamic>{'title': pickerTitleText(l10n, slot)},
    );
    if (item == null || !context.mounted) {
      return;
    }
    ref.read(safetyProvider.notifier).setMedicine(slot: slot, item: item);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/reminder_list_provider.dart';
import '../widgets/reminder_list_widgets.dart';
import '../widgets/reminder_card_widget.dart';
import 'reminder_edit_page.dart';

/// 用药提醒列表页。
class ReminderListPage extends ConsumerWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderListProvider);
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = ref.read(currentUserProvider)?.hasData == true &&
        (ref.read(currentUserProvider)?.id ?? '').trim().isNotEmpty;

    return AppCanvasPageScaffold(
      appBar: AppBar(
        title: Text(l10n?.reminderListTitle ?? '用药提醒'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed:
                isLoggedIn && !state.isLoading
                    ? () => _sync(ref, context)
                    : null,
            icon: state.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      appBarSpacing: 30,
      accentColor: const Color(0xFF10B981),
      secondaryAccentColor: const Color(0xFF0EA5E9),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton.extended(
              onPressed:
                  state.isLoading ? null : () => _openCreate(context, ref),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n?.reminderAddButton ?? '新增提醒'),
            )
          : null,
      child: !isLoggedIn
          ? const ReminderNeedLoginCard()
          : RefreshIndicator(
              onRefresh: () => _sync(ref, context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                children: [
                  ReminderListHeroCard(
                    itemCount: state.items.length,
                    enabledCount:
                        state.items.where((i) => i.enabled).length,
                    disabledCount:
                        state.items.length -
                        state.items.where((i) => i.enabled).length,
                  ),
                  const SizedBox(height: 10),
                  if (state.error != null)
                    ReminderErrorBanner(text: state.error!),
                  if (state.items.isEmpty && !state.loading)
                    const ReminderEmptyCard(),
                  ...state.items.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            index == state.items.length - 1 ? 0 : 8,
                      ),
                      child: ReminderCard(
                        item: item,
                        busy: ref
                            .read(reminderListProvider.notifier)
                            .isBusy(item.id),
                        onTap: () => _openEdit(context, ref, item),
                        onToggle: (value) =>
                            _toggleEnabled(ref, context, item, value),
                        onDelete: () =>
                            _confirmAndDelete(context, ref, item),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Future<void> _sync(WidgetRef ref, BuildContext context) async {
    final error =
        await ref.read(reminderListProvider.notifier).sync();
    if (error != null && context.mounted) {
      ToastUtils.instance.showError(context, error);
    }
  }

  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    final plan = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => const ReminderEditPage(),
      ),
    );
    if (!context.mounted || plan == null) return;
    await ref.read(reminderListProvider.notifier).applySavedPlan(plan);
  }

  Future<void> _openEdit(
    BuildContext context,
    WidgetRef ref,
    ReminderPlan plan,
  ) async {
    final next = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => ReminderEditPage(initial: plan),
      ),
    );
    if (!context.mounted || next == null) return;
    await ref.read(reminderListProvider.notifier).applySavedPlan(next);
  }

  Future<void> _toggleEnabled(
    WidgetRef ref,
    BuildContext context,
    ReminderPlan plan,
    bool enabled,
  ) async {
    final error = await ref
        .read(reminderListProvider.notifier)
        .toggleEnabled(plan, enabled);
    if (error != null && context.mounted) {
      ToastUtils.instance.showError(context, error);
    }
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    ReminderPlan plan,
  ) async {
    final confirmed = await _confirmDeletePlan(context, plan);
    if (!context.mounted || !confirmed) return;
    final error =
        await ref.read(reminderListProvider.notifier).deletePlan(plan);
    if (error != null && context.mounted) {
      ToastUtils.instance.showError(context, error);
    } else if (context.mounted) {
      ToastUtils.instance.show(
        context,
        AppLocalizations.of(context)?.reminderDeletedToast ?? '已删除',
      );
    }
  }

  Future<bool> _confirmDeletePlan(
    BuildContext context,
    ReminderPlan plan,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          child: AppSectionCard(
            accentColor: const Color(0xFFF59E0B),
            secondaryColor: const Color(0xFFEF4444),
            ornamentKey: 'reminders.list.delete-dialog',
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: appTintedSurface(
                          dialogContext,
                          scheme.error,
                          lightAlpha: 0.12,
                          darkAlpha: 0.22,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: scheme.error,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.reminderDeleteDialogTitle ?? '删除提醒',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.reminderDeleteDialogContent(
                        plan.productName,
                        plan.time,
                      ) ??
                      '确定要删除"${plan.productName} ${plan.time}"吗？',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: Text(
                        l10n?.reminderDeleteCancel ?? '取消',
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                      ),
                      child: Text(
                        l10n?.reminderDeleteConfirm ?? '删除',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}

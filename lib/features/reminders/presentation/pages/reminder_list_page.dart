import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/shared/widgets/app_surface.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/viewmodels/reminder.dart';

import '../controllers/reminder_list_controller.dart';
import '../widgets/reminder_list_widgets.dart';
import '../widgets/reminder_card_widget.dart';
import 'reminder_edit_page.dart';

/// 用药提醒列表页。
///
/// 页面只负责展示列表、页面跳转和删除确认，业务状态由 controller 承接。
class ReminderListPage extends StatelessWidget {
  /// 创建用药提醒列表页组件。
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReminderListController>(
      init: ReminderListController(),
      global: false,
      builder: (controller) {
        final l10n = AppLocalizations.of(context);
        return AppCanvasPageScaffold(
          appBar: AppBar(
            title: Text(l10n?.reminderListTitle ?? '用药提醒'),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                onPressed: controller.isLoggedIn && !controller.loading
                    ? controller.sync
                    : null,
                icon: controller.loading
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
          floatingActionButton: controller.isLoggedIn
              ? FloatingActionButton.extended(
                  onPressed: controller.loading
                      ? null
                      : () => _openCreate(context, controller),
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n?.reminderAddButton ?? '新增提醒'),
                )
              : null,
          child: !controller.isLoggedIn
              ? const ReminderNeedLoginCard()
              : RefreshIndicator(
                  onRefresh: controller.sync,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                    children: [
                      ReminderListHeroCard(
                        itemCount: controller.items.length,
                        enabledCount: controller.enabledCount,
                        disabledCount: controller.disabledCount,
                      ),
                      const SizedBox(height: 10),
                      if (controller.error != null)
                        ReminderErrorBanner(text: controller.error!),
                      if (controller.items.isEmpty && !controller.loading)
                        const ReminderEmptyCard(),
                      ...controller.items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index == controller.items.length - 1 ? 0 : 8,
                          ),
                          child: ReminderCard(
                            item: item,
                            busy: controller.isBusy(item.id),
                            onTap: () => _openEdit(context, controller, item),
                            onToggle: (value) =>
                                controller.toggleEnabled(item, value),
                            onDelete: () =>
                                _confirmAndDelete(context, controller, item),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
        );
      },
    );
  }

  /// 打开"新增提醒"页并接住编辑结果。
  Future<void> _openCreate(
    BuildContext context,
    ReminderListController controller,
  ) async {
    final plan = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => const ReminderEditPage(),
      ),
    );
    if (!context.mounted || plan == null) {
      return;
    }
    await controller.applySavedPlan(plan);
  }

  /// 打开"编辑提醒"页并接住更新结果。
  Future<void> _openEdit(
    BuildContext context,
    ReminderListController controller,
    ReminderPlan plan,
  ) async {
    final next = await Navigator.of(context).push<ReminderPlan>(
      MaterialPageRoute<ReminderPlan>(
        builder: (_) => ReminderEditPage(initial: plan),
      ),
    );
    if (!context.mounted || next == null) {
      return;
    }
    await controller.applySavedPlan(next);
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    ReminderListController controller,
    ReminderPlan plan,
  ) async {
    final confirmed = await _confirmDeletePlan(context, plan);
    if (!context.mounted || !confirmed) {
      return;
    }
    await controller.deletePlan(plan);
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
                    fontSize: 13.2,
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 44),
                          side: BorderSide(
                            color: scheme.outline.withValues(alpha: 0.7),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteCancel ?? '取消'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n?.reminderDeleteConfirm ?? '删除'),
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

    return result == true;
  }
}

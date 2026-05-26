import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/shared/widgets/app_canvas.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/toast_utils.dart';

import '../providers/checkin_provider.dart';
import '../widgets/checkin_hero_card.dart';
import '../widgets/checkin_need_login_card.dart';
import '../widgets/checkin_empty_card.dart';
import '../widgets/checkin_item_card.dart';

/// 用药打卡页。
///
/// 状态由 [checkinItemsProvider]（Riverpod AsyncNotifier）管理，
/// 替代旧 GetX `CheckInController`。
class CheckInPage extends ConsumerWidget {
  const CheckInPage({super.key, this.reminderGateway});

  final ReminderLocalGateway? reminderGateway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gateway = reminderGateway;
    if (gateway == null) {
      return const _CheckInContent();
    }
    final user = ref.watch(currentUserProvider);
    return ProviderScope(
      overrides: [
        checkinReminderGatewayProvider.overrideWithValue(gateway),
        currentUserProvider.overrideWithValue(user),
      ],
      child: const _CheckInContent(),
    );
  }
}

class _CheckInContent extends ConsumerWidget {
  const _CheckInContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(checkinItemsProvider);
    final user = ref.watch(currentUserProvider);
    final isLoggedIn = user?.hasData ?? false;
    final items = itemsAsync.hasValue
        ? itemsAsync.value!
        : const <ReminderItem>[];
    final errorText = itemsAsync.error != null
        ? MessageUtils.extractError(itemsAsync.error!)
        : null;

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n?.checkInPageTitle ?? '用药打卡'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed: isLoggedIn && !itemsAsync.isLoading
                ? () => ref.invalidate(checkinItemsProvider)
                : null,
            icon: itemsAsync.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: AppCanvas(
        accentColor: const Color(0xFFF59E0B),
        secondaryAccentColor: const Color(0xFFBFD8FF),
        child: !isLoggedIn
            ? const CheckInNeedLoginCard()
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(checkinItemsProvider),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
                  children: [
                    CheckInHeroCard(items: items),
                    const SizedBox(height: 8),
                    if (errorText != null) _buildErrorBanner(errorText),
                    if (items.isEmpty &&
                        !itemsAsync.isLoading &&
                        errorText == null)
                      const CheckInEmptyCard(),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == items.length - 1 ? 0 : 6,
                        ),
                        child: CheckInItemCard(
                          item: item,
                          onCheckIn: () => _toggleCheckIn(context, ref, item),
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorBanner(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCheckIn(
    BuildContext context,
    WidgetRef ref,
    ReminderItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    if (item.done) {
      await _confirmAndMarkUndone(context, ref, item);
      return;
    }
    final notifier = ref.read(checkinItemsProvider.notifier);
    await notifier.markDone(item);
    if (!context.mounted) return;
    ToastUtils.instance.show(
      context,
      l10n?.checkInMarkedDoneToast ?? 'Saved on this device',
    );
  }

  Future<void> _confirmAndMarkUndone(
    BuildContext context,
    WidgetRef ref,
    ReminderItem item,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n?.checkInUndoDialogTitle ?? '撤销本地打卡'),
          content: Text(
            l10n?.checkInUndoDialogContent ??
                '当前用药打卡只保存在本机，撤销后会立即修改当前设备显示。确定继续吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n?.checkInUndoDialogCancel ?? '取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n?.checkInUndoDialogConfirm ?? '撤销本地打卡'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!context.mounted) return;
    final notifier = ref.read(checkinItemsProvider.notifier);
    await notifier.markUndone(item);
    if (!context.mounted) return;
    ToastUtils.instance.show(
      context,
      l10n?.checkInMarkedUndoneToast ?? 'Marked as not checked in',
    );
  }
}

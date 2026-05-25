import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/shared/models/home.dart';

/// 打卡条目列表 provider。
///
/// 替代旧 GetX `CheckInController` 的 loading / error / items 状态。
final checkinItemsProvider =
    AsyncNotifierProvider<CheckInNotifier, List<ReminderItem>>(
      CheckInNotifier.new,
    );

/// 打卡状态管理器。
///
/// `build()` 中 `ref.watch(currentUserProvider)` 感知登录状态变化，
/// 自动重新加载条目。`markDone` / `markUndone` 执行后触发 reload。
class CheckInNotifier extends AsyncNotifier<List<ReminderItem>> {
  @override
  Future<List<ReminderItem>> build() async {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return const [];
    return reminderLocalGateway.loadTodayItems(userId);
  }

  Future<void> markDone(ReminderItem item) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return;
    if (item.id.trim().isEmpty) return;

    await reminderLocalGateway.markTodayDone(userId: userId, item: item);
    ref.invalidateSelf();
  }

  Future<void> markUndone(ReminderItem item) async {
    final user = ref.read(currentUserProvider);
    final userId = user?.id ?? '';
    if (userId.isEmpty) return;
    if (item.id.trim().isEmpty) return;

    await reminderLocalGateway.markTodayUndone(
      userId: userId,
      reminderId: item.id.trim(),
    );
    ref.invalidateSelf();
  }
}

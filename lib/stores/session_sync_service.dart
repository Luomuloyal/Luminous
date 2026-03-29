import 'package:get/get.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/stores/reminder_local_store.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/viewmodels/reminder.dart';

/// 当前用户登录后的会话同步服务。
///
/// 负责在登录成功或启动恢复登录态后，同步：
/// - “我的药品”；
/// - “用药提醒”。
class SessionSyncService {
  /// 私有构造函数。
  SessionSyncService._();

  /// 全局单例入口。
  static final SessionSyncService instance = SessionSyncService._();

  /// 串行化会话同步请求，避免不同用户会话互相覆盖。
  Future<void> _syncTail = Future<void>.value();

  /// 同步指定用户的云端数据。
  ///
  /// 返回所有失败项的可读错误文案；全部成功则返回空列表。
  Future<List<String>> syncForUser(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      await NotificationService.instance.cancelAll();
      return const [];
    }
    final run = _syncTail.catchError((_) {}).then((_) => _runSyncForUser(uid));
    _syncTail = run.then<void>((_) {}, onError: (_, _) {});
    return run;
  }

  Future<List<String>> _runSyncForUser(String userId) async {
    if (!_shouldApplySync(userId)) {
      return const [];
    }

    final errors = <String>[];
    try {
      await myMedicineRepository.syncRemote(userId);
    } catch (e) {
      errors.add(
        _buildErrorText(AppI18nText.pick(zh: '我的药品', en: 'My Medicines'), e),
      );
    }

    if (!_shouldApplySync(userId)) {
      return errors;
    }

    try {
      await _syncReminders(userId);
    } catch (e) {
      errors.add(
        _buildErrorText(
          AppI18nText.pick(zh: '用药提醒', en: 'Medication Reminders'),
          e,
        ),
      );
    }

    if (!_shouldApplySync(userId)) {
      return errors;
    }
    return errors;
  }

  /// 同步远端提醒列表，并重建本地通知。
  Future<void> _syncReminders(String userId) async {
    final response = await ReminderApi.list(userId: userId);
    final items = List<ReminderPlan>.from(response.result.items)
      ..sort((a, b) => a.time.compareTo(b.time));
    await reminderLocalStore.replaceForUser(userId, items);
    if (!_shouldApplySync(userId)) {
      return;
    }
    await NotificationService.instance.rescheduleAll(items);
  }

  bool _shouldApplySync(String userId) {
    if (!Get.isRegistered<UserController>()) {
      return true;
    }
    final currentUserId = Get.find<UserController>().user.value?.id ?? '';
    return currentUserId.trim() == userId.trim();
  }

  /// 生成同步失败提示文案。
  String _buildErrorText(String module, Object error) {
    final text = MessageUtils.extractError(error);
    return AppI18nText.pick(
      zh: '$module同步失败：$text',
      en: '$module sync failed: $text',
    );
  }
}

/// 对外暴露的全局会话同步服务实例。
final sessionSyncService = SessionSyncService.instance;

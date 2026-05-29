import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/drug/data/my_medicine_repository.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/utils/app_i18n_text.dart';
import 'package:luminous/utils/message_utils.dart';
import 'package:luminous/utils/notification_service.dart';

/// 当前用户登录后的会话同步服务。
///
/// 负责在登录成功或启动恢复登录态后，同步：
/// - “我的药品”；
/// - “用药提醒”。
/// 当前用户的会话同步服务 provider。
///
/// 通过 [currentUserProvider] 感知登录态，无需依赖全局容器。
final sessionSyncServiceProvider = Provider<SessionSyncService>((ref) {
  return SessionSyncService(
    getCurrentUserId: () => ref.read(currentUserProvider)?.id ?? '',
  );
});

class SessionSyncService {
  /// 创建会话同步服务。
  ///
  /// [getCurrentUserId] 返回当前登录用户的 id，用于判断同步是否仍需继续。
  SessionSyncService({required String Function() getCurrentUserId})
    // ignore: prefer_initializing_formals
    : _getCurrentUserId = getCurrentUserId;

  final String Function() _getCurrentUserId;

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
    await reminderLocalGateway.syncRemoteToLocal(userId);
    if (!_shouldApplySync(userId)) {
      return;
    }
  }

  bool _shouldApplySync(String userId) {
    return _getCurrentUserId().trim() == userId.trim();
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

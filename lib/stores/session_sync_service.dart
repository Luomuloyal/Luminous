import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/my_medicine_repository.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/viewmodels/reminder.dart';
import 'package:sqflite/sqflite.dart';

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

  /// 当前是否正处于同步中。
  bool _syncing = false;

  /// 同步指定用户的云端数据。
  ///
  /// 返回所有失败项的可读错误文案；全部成功则返回空列表。
  Future<List<String>> syncForUser(String? userId) async {
    final uid = (userId ?? '').trim();
    if (uid.isEmpty) {
      await NotificationService.instance.cancelAll();
      return const [];
    }
    if (_syncing) {
      return const [];
    }

    _syncing = true;
    final errors = <String>[];
    try {
      try {
        await myMedicineRepository.syncRemote(uid);
      } catch (e) {
        errors.add(_buildErrorText('我的药品', e));
      }

      try {
        await _syncReminders(uid);
      } catch (e) {
        errors.add(_buildErrorText('用药提醒', e));
      }
    } finally {
      _syncing = false;
    }
    return errors;
  }

  /// 同步远端提醒列表，并重建本地通知。
  Future<void> _syncReminders(String userId) async {
    final response = await ReminderApi.list(userId: userId);
    final items = List<ReminderPlan>.from(response.result.items)
      ..sort((a, b) => a.time.compareTo(b.time));
    await _cacheRemindersToLocal(userId, items);
    await NotificationService.instance.rescheduleAll(items);
  }

  /// 把提醒计划列表写入本地缓存。
  Future<void> _cacheRemindersToLocal(
    String userId,
    List<ReminderPlan> items,
  ) async {
    final db = await AppDatabase.instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction((txn) async {
      await txn.delete('reminders', where: 'userId = ?', whereArgs: [userId]);
      for (final item in items) {
        if (item.id.trim().isEmpty) continue;
        await txn.insert('reminders', {
          'remoteId': item.id,
          'userId': userId,
          'time': item.time,
          'drugCode': item.drugCode,
          'approvalNo': item.approvalNo,
          'productName': item.productName,
          'subtitle': item.subtitle,
          'enabled': item.enabled ? 1 : 0,
          'repeatRule': item.repeatRule,
          'method': item.method,
          'updatedAt': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  /// 生成同步失败提示文案。
  String _buildErrorText(String module, Object error) {
    final text = error.toString().replaceFirst('Exception: ', '');
    return '$module同步失败：$text';
  }
}

/// 对外暴露的全局会话同步服务实例。
final sessionSyncService = SessionSyncService.instance;

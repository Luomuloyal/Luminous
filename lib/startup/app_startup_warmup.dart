import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/ornament_controller.dart';
import 'package:luminous/stores/reminder_local_gateway.dart';
import 'package:luminous/stores/session_sync_service.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/notification_service.dart';

/// 首帧渲染后的异步预热协调器。
class AppStartupWarmup {
  AppStartupWarmup({
    required UserController userController,
    required OrnamentController ornamentController,
    ReminderLocalGateway? reminderGateway,
    Future<void> Function(String userId)? syncSession,
  }) : _userController = userController,
       _ornamentController = ornamentController,
       _reminderGateway = reminderGateway ?? reminderLocalGateway,
       _syncSession = syncSession ?? sessionSyncService.syncForUser;

  final UserController _userController;
  final OrnamentController _ornamentController;
  final ReminderLocalGateway _reminderGateway;
  final Future<void> Function(String userId) _syncSession;
  bool _started = false;

  /// 在首帧之后启动所有预热任务。
  void start() {
    if (_started) {
      return;
    }
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_runWarmup());
    });
  }

  Future<void> _runWarmup() async {
    await Future<void>.delayed(Duration.zero);

    unawaited(_warmOrnaments());
    unawaited(_warmTokenStore());
    unawaited(_restoreUserSession());
    unawaited(_warmDatabase());
    unawaited(_warmNotificationSdk());
  }

  Future<void> _warmOrnaments() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 12));
      if (!_ornamentController.isReady) {
        await _ornamentController.init();
      }
      await _ornamentController.warmup();
    } catch (_) {
      // 装饰预热失败时保持确定性兜底布局，不影响功能。
    }
  }

  Future<void> _warmTokenStore() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await tokenManager.init();
    } catch (_) {
      // 预热失败时保持惰性初始化，不影响应用使用。
    }
  }

  Future<void> _restoreUserSession() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await _userController.init();

      final userId = _userController.user.value?.id;
      if ((userId ?? '').trim().isNotEmpty) {
        final resolvedUserId = userId?.trim() ?? '';
        await _reminderGateway.rescheduleFromLocal(resolvedUserId);
        unawaited(_syncCloudSession(resolvedUserId));
      }
    } catch (_) {
      // 登录态恢复失败时回退到未登录状态，不阻塞首屏。
    }
  }

  Future<void> _syncCloudSession(String userId) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 260));
      await _syncSession(userId);
    } catch (_) {
      // 云端同步失败留给页面层或后续操作处理。
    }
  }

  Future<void> _warmDatabase() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      await AppDatabase.instance.database;
    } catch (_) {
      // 数据库预热失败时保持首次使用再初始化。
    }
  }

  Future<void> _warmNotificationSdk() async {
    if (kIsWeb) {
      return;
    }
    try {
      await Future<void>.delayed(const Duration(milliseconds: 360));
      await NotificationService.instance.init();
    } catch (_) {
      // 通知插件初始化失败时保持按需初始化。
    }
  }
}

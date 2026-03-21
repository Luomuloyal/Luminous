import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:luminous/stores/app_database.dart';
import 'package:luminous/stores/session_sync_service.dart';
import 'package:luminous/stores/token_manager.dart';
import 'package:luminous/stores/user_controller.dart';
import 'package:luminous/utils/notification_service.dart';

/// 首帧渲染后的异步预热协调器。
///
/// 目标是把 SharedPreferences、数据库、通知插件和网络同步等重操作
/// 从 `main()` 移到首帧之后，降低冷启动首帧等待时间。
class AppStartupWarmup {
  AppStartupWarmup({required UserController userController})
    : _userController = userController;

  final UserController _userController;
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

    // SharedPreferences 相关预热最先开始，但不阻塞其它任务。
    unawaited(_warmTokenStore());

    // 恢复用户态是唯一稍微关键一点的首帧后任务；恢复完成后再决定是否云同步。
    unawaited(_restoreUserSession());

    // 数据库和第三方 SDK 都延后一点，避免首帧后瞬间打满 I/O。
    unawaited(_warmDatabase());
    unawaited(_warmNotificationSdk());
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
        unawaited(_syncCloudSession(userId!));
      }
    } catch (_) {
      // 登录态恢复失败时回退到未登录状态，不阻塞首屏。
    }
  }

  Future<void> _syncCloudSession(String userId) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 260));
      await sessionSyncService.syncForUser(userId);
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

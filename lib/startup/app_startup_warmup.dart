import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:luminous/core/local_storage/app_database.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/constants/global_constants.dart' as g;
import 'package:luminous/core/local_storage/token_manager.dart';
import 'package:luminous/features/auth/data/session_sync_service.dart';
import 'package:luminous/features/auth/data/token_refresh_service.dart';
import 'package:luminous/utils/notification_service.dart';

/// 首帧渲染后的异步预热协调器。
class AppStartupWarmup {
  AppStartupWarmup({
    required Future<void> Function() restoreUserSession,
    required Future<void> Function() warmOrnaments,
    required String? Function() readCurrentUserId,
    required SessionSyncService sessionSyncService,
    ReminderLocalGateway? reminderGateway,
    Future<void> Function(String userId)? syncSession,
  }) : _restoreUserSessionTask = restoreUserSession,
       _warmOrnamentsTask = warmOrnaments,
       // ignore: prefer_initializing_formals
       _readCurrentUserId = readCurrentUserId,
       _syncSession = syncSession ?? sessionSyncService.syncForUser,
       _reminderGateway = reminderGateway ?? reminderLocalGateway;

  final Future<void> Function() _restoreUserSessionTask;
  final Future<void> Function() _warmOrnamentsTask;
  final String? Function() _readCurrentUserId;
  final Future<void> Function(String userId) _syncSession;
  final ReminderLocalGateway _reminderGateway;
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
      await _warmOrnamentsTask();
    } catch (_) {
      // 装饰预热失败时保持确定性兜底布局，不影响功能。
    }
  }

  Future<void> _warmTokenStore() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      await tokenManager.init();

      // Initialise the global token refresh service.
      // The Dio interceptor references this singleton to debounce 401s.
      final service = TokenRefreshService(baseUrl: g.GlobalConstants.BASE_URL);
      service.onSessionExpired(() {
        // Session expired callback is handled by the Riverpod provider layer.
        // The container reference is passed in via readCurrentUserId for
        // session-aware operations below.
      });
      tokenRefreshService = service;
    } catch (_) {
      // 预热失败时保持惰性初始化，不影响应用使用。
    }
  }

  Future<void> _restoreUserSession() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await _restoreUserSessionTask();

      final userId = _readCurrentUserId();
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

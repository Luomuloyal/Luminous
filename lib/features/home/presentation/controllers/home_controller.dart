import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:luminous/core/providers/global_provider_container.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/utils/toast_utils.dart';
import 'package:luminous/shared/models/home.dart';

/// 首页页面级控制器。
///
/// 负责维护健康提示、演示提醒、打卡记录回流，以及登录态切换后的本地同步。
class HomeController extends GetxController {
  HomeController({ReminderLocalGateway? reminderGateway})
    : _reminderGateway = reminderGateway ?? reminderLocalGateway;

  final ReminderLocalGateway _reminderGateway;

  final ValueNotifier<String> todayTipNotifier = ValueNotifier<String>('');
  final List<String> _healthTips = <String>[];
  final List<HomeReminderItemData> _demoReminders = <HomeReminderItemData>[];
  final List<HomeCheckInRecordData> _demoCheckInRecords =
      <HomeCheckInRecordData>[];
  final List<HomeReminderItemData> _reminders = <HomeReminderItemData>[];
  final List<HomeCheckInRecordData> _checkInRecords = <HomeCheckInRecordData>[];

  ProviderSubscription? _userWorker;
  ProviderSubscription? _sessionReadyWorker;
  StreamSubscription<int>? _revisionSubscription;
  bool _loadingReminders = false;
  bool _loadingCheckInRecords = false;
  bool _checkInReloadQueued = false;
  int _checkInRequestId = 0;
  int _reminderRequestId = 0;
  String? _lastRequestedUserId;

  List<String> get healthTips => List<String>.unmodifiable(_healthTips);
  List<HomeReminderItemData> get reminders =>
      List<HomeReminderItemData>.unmodifiable(_reminders);
  List<HomeCheckInRecordData> get checkInRecords =>
      List<HomeCheckInRecordData>.unmodifiable(_checkInRecords);
  bool get loadingReminders => _loadingReminders;
  bool get loadingCheckInRecords => _loadingCheckInRecords;
  String get currentUserId =>
      (globalProviderContainer.read(currentUserProvider)?.id ?? '').trim();

  @override
  void onInit() {
    super.onInit();
    _userWorker = globalProviderContainer.listen(currentUserProvider, (
      previous,
      next,
    ) {
      refreshIfReady();
    });
    _sessionReadyWorker = globalProviderContainer.listen(
      userSessionReadyProvider,
      (_, ready) {
        if (ready) {
          _lastRequestedUserId = null;
          refreshIfReady();
        }
      },
    );
    refreshIfReady();
  }

  @override
  void onClose() {
    _userWorker?.close();
    _sessionReadyWorker?.close();
    _revisionSubscription?.cancel();
    todayTipNotifier.dispose();
    super.onClose();
  }

  void applyLocalizedData({
    required List<String> healthTips,
    required List<HomeReminderItemData> demoReminders,
    required List<HomeCheckInRecordData> demoCheckInRecords,
  }) {
    _healthTips
      ..clear()
      ..addAll(healthTips);
    _demoReminders
      ..clear()
      ..addAll(demoReminders);
    _demoCheckInRecords
      ..clear()
      ..addAll(demoCheckInRecords);
    _reminders
      ..clear()
      ..addAll(_demoReminders);

    if (_healthTips.isNotEmpty &&
        (todayTipNotifier.value.isEmpty ||
            !_healthTips.contains(todayTipNotifier.value))) {
      todayTipNotifier.value =
          _healthTips[Random().nextInt(_healthTips.length)];
    }

    if (currentUserId.isEmpty) {
      _loadingReminders = false;
      _loadingCheckInRecords = false;
      _checkInRecords
        ..clear()
        ..addAll(_demoCheckInRecords);
    }

    update();
  }

  void refreshIfReady({bool force = false}) {
    if (!globalProviderContainer.read(userSessionReadyProvider)) {
      return;
    }

    final userId = currentUserId;
    _bindRevision(userId);
    _reminders
      ..clear()
      ..addAll(_demoReminders);

    if (userId.isEmpty) {
      _lastRequestedUserId = userId;
      _checkInReloadQueued = false;
      _loadingReminders = false;
      _loadingCheckInRecords = false;
      _reminders
        ..clear()
        ..addAll(_demoReminders);
      _checkInRecords
        ..clear()
        ..addAll(_demoCheckInRecords);
      update();
      return;
    }

    if (_lastRequestedUserId != null && _lastRequestedUserId != userId) {
      _reminders.clear();
      _checkInRecords.clear();
      update();
    } else {
      update();
    }

    if (!force && _lastRequestedUserId == userId) {
      return;
    }

    _lastRequestedUserId = userId;
    unawaited(loadReminders(syncRemote: true));
    unawaited(loadCheckInRecords());
  }

  Future<void> loadReminders({bool syncRemote = false}) async {
    final userId = currentUserId;
    if (userId.isEmpty) {
      _loadingReminders = false;
      _reminders
        ..clear()
        ..addAll(_demoReminders);
      update();
      return;
    }

    final requestId = ++_reminderRequestId;
    _loadingReminders = true;
    update();

    try {
      final localItems = await _reminderGateway.loadTodayItems(userId);
      if (!_canApplyReminderResult(requestId, userId)) {
        return;
      }
      _applyReminderItems(localItems);

      if (syncRemote) {
        await _reminderGateway.syncRemoteToLocal(userId);
        if (!_canApplyReminderResult(requestId, userId)) {
          return;
        }
        final refreshedItems = await _reminderGateway.loadTodayItems(userId);
        if (!_canApplyReminderResult(requestId, userId)) {
          return;
        }
        _applyReminderItems(refreshedItems);
      }
    } catch (_) {
      if (_canApplyReminderResult(requestId, userId)) {
        _reminders.clear();
        update();
      }
    } finally {
      if (_isActiveReminderRequest(requestId) && !isClosed) {
        _loadingReminders = false;
        update();
      }
    }
  }

  Future<void> loadCheckInRecords() async {
    if (_loadingCheckInRecords) {
      _checkInReloadQueued = true;
      return;
    }

    final userId = currentUserId;
    if (userId.isEmpty) {
      _checkInReloadQueued = false;
      _loadingCheckInRecords = false;
      _checkInRecords
        ..clear()
        ..addAll(_demoCheckInRecords);
      update();
      return;
    }

    final requestId = ++_checkInRequestId;
    _loadingCheckInRecords = true;
    update();

    try {
      final records = await _reminderGateway.loadCheckInRecords(
        userId,
        maxDays: 7,
        maxItems: 160,
      );
      if (!_canApplyCheckInResult(requestId, userId)) {
        return;
      }
      _checkInRecords
        ..clear()
        ..addAll(records);
      update();
    } catch (_) {
      if (_canApplyCheckInResult(requestId, userId)) {
        _checkInRecords.clear();
        update();
      }
    } finally {
      if (_isActiveCheckInRequest(requestId) && !isClosed) {
        _loadingCheckInRecords = false;
        update();
      }
      if (_isActiveCheckInRequest(requestId) &&
          _checkInReloadQueued &&
          !isClosed) {
        _checkInReloadQueued = false;
        unawaited(loadCheckInRecords());
      }
    }
  }

  Future<void> refreshHomeData(BuildContext context) async {
    final userId = currentUserId;
    if (userId.isEmpty) {
      _reminders
        ..clear()
        ..addAll(_demoReminders);
      _checkInRecords
        ..clear()
        ..addAll(_demoCheckInRecords);
      update();
      return;
    }

    try {
      await _reminderGateway.syncRemoteToLocal(userId);
      if (isClosed || !context.mounted || userId != currentUserId) {
        return;
      }
      await loadReminders();
      await loadCheckInRecords();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      ToastUtils.instance.showError(context, error);
    }
  }

  void cycleHealthTip() {
    if (_healthTips.length <= 1) {
      return;
    }

    final currentTip = todayTipNotifier.value;
    final nextTips = _healthTips.where((tip) => tip != currentTip).toList();
    if (nextTips.isEmpty) {
      return;
    }

    updateTodayTip(nextTips[Random().nextInt(nextTips.length)]);
  }

  void updateTodayTip(String nextTip) {
    if (nextTip == todayTipNotifier.value) {
      return;
    }
    todayTipNotifier.value = nextTip;
  }

  void _bindRevision(String userId) {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) {
      return;
    }
    _revisionSubscription = _reminderGateway.watchRevision(scopedUserId).listen(
      (_) {
        if (isClosed) {
          return;
        }
        unawaited(loadReminders());
        unawaited(loadCheckInRecords());
      },
    );
  }

  void _applyReminderItems(List<ReminderItem> items) {
    _reminders
      ..clear()
      ..addAll(items.map(_mapReminderItem));
    update();
  }

  HomeReminderItemData _mapReminderItem(ReminderItem item) {
    final time = item.time.trim();
    final title = item.title.trim();
    final titleText = time.isEmpty ? title : '$time $title';
    return HomeReminderItemData(
      icon: item.done ? Icons.task_alt_rounded : Icons.access_time_rounded,
      title: titleText.isEmpty
          ? (item.subtitle.trim().isEmpty ? '提醒事项' : item.subtitle.trim())
          : titleText,
      dosage: item.dosage,
      subtitle: item.subtitle,
      done: item.done,
    );
  }

  bool _canApplyReminderResult(int requestId, String userId) {
    return !isClosed &&
        _isActiveReminderRequest(requestId) &&
        userId == currentUserId;
  }

  bool _isActiveReminderRequest(int requestId) {
    return requestId == _reminderRequestId;
  }

  bool _canApplyCheckInResult(int requestId, String userId) {
    return !isClosed &&
        _isActiveCheckInRequest(requestId) &&
        userId == currentUserId;
  }

  bool _isActiveCheckInRequest(int requestId) {
    return requestId == _checkInRequestId;
  }
}

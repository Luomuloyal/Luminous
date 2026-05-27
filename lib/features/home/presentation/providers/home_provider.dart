import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/shared/models/home.dart';

final homeReminderGatewayProvider = Provider<ReminderLocalGateway>(
  (ref) => reminderLocalGateway,
);

class HomeState {
  const HomeState({
    this.healthTips = const [],
    this.reminders = const [],
    this.checkInRecords = const [],
    this.loadingReminders = false,
    this.loadingCheckInRecords = false,
    this.demoReminders = const [],
    this.demoCheckInRecords = const [],
    this.todayTip = '',
    this.lastRequestedUserId,
  });

  final List<String> healthTips;
  final List<HomeReminderItemData> reminders;
  final List<HomeCheckInRecordData> checkInRecords;
  final bool loadingReminders;
  final bool loadingCheckInRecords;
  final List<HomeReminderItemData> demoReminders;
  final List<HomeCheckInRecordData> demoCheckInRecords;
  final String todayTip;
  final String? lastRequestedUserId;

  HomeState copyWith({
    List<String>? healthTips,
    List<HomeReminderItemData>? reminders,
    List<HomeCheckInRecordData>? checkInRecords,
    bool? loadingReminders,
    bool? loadingCheckInRecords,
    List<HomeReminderItemData>? demoReminders,
    List<HomeCheckInRecordData>? demoCheckInRecords,
    String? todayTip,
    String? lastRequestedUserId,
  }) {
    return HomeState(
      healthTips: healthTips ?? this.healthTips,
      reminders: reminders ?? this.reminders,
      checkInRecords: checkInRecords ?? this.checkInRecords,
      loadingReminders: loadingReminders ?? this.loadingReminders,
      loadingCheckInRecords:
          loadingCheckInRecords ?? this.loadingCheckInRecords,
      demoReminders: demoReminders ?? this.demoReminders,
      demoCheckInRecords: demoCheckInRecords ?? this.demoCheckInRecords,
      todayTip: todayTip ?? this.todayTip,
      lastRequestedUserId:
          lastRequestedUserId ?? this.lastRequestedUserId,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  ReminderLocalGateway get _gateway => ref.read(homeReminderGatewayProvider);

  StreamSubscription<int>? _revisionSubscription;
  int _reminderRequestId = 0;
  int _checkInRequestId = 0;
  bool _checkInReloadQueued = false;

  String get _currentUserId {
    final user = ref.read(currentUserProvider);
    return (user?.id ?? '').trim();
  }

  @override
  HomeState build() {
    ref.onDispose(() {
      _revisionSubscription?.cancel();
    });

    ref.listen(currentUserProvider, (prev, next) {
      Future.microtask(() => refreshIfReady());
    });

    ref.listen(userSessionReadyProvider, (prev, ready) {
      if (ready && prev != ready) {
        Future.microtask(() {
          state = state.copyWith(lastRequestedUserId: null);
          refreshIfReady();
        });
      }
    });

    return const HomeState();
  }

  void start() {
    refreshIfReady(force: true);
  }

  void applyLocalizedData({
    required List<String> healthTips,
    required List<HomeReminderItemData> demoReminders,
    required List<HomeCheckInRecordData> demoCheckInRecords,
  }) {
    final newReminders = List<HomeReminderItemData>.from(demoReminders);

    String nextTip = state.todayTip;
    if (healthTips.isNotEmpty &&
        (nextTip.isEmpty || !healthTips.contains(nextTip))) {
      nextTip = healthTips[Random().nextInt(healthTips.length)];
    }

    if (_currentUserId.isEmpty) {
      state = state.copyWith(
        healthTips: List<String>.from(healthTips),
        demoReminders: List<HomeReminderItemData>.from(demoReminders),
        demoCheckInRecords:
            List<HomeCheckInRecordData>.from(demoCheckInRecords),
        reminders: newReminders,
        checkInRecords: List<HomeCheckInRecordData>.from(demoCheckInRecords),
        loadingReminders: false,
        loadingCheckInRecords: false,
        todayTip: nextTip,
      );
    } else {
      state = state.copyWith(
        healthTips: List<String>.from(healthTips),
        demoReminders: List<HomeReminderItemData>.from(demoReminders),
        demoCheckInRecords:
            List<HomeCheckInRecordData>.from(demoCheckInRecords),
        todayTip: nextTip,
      );
    }
  }

  void refreshIfReady({bool force = false}) {
    if (!ref.read(userSessionReadyProvider)) return;

    final userId = _currentUserId;
    _bindRevision(userId);

    if (userId.isEmpty) {
      _checkInReloadQueued = false;
      state = state.copyWith(
        lastRequestedUserId: userId,
        loadingReminders: false,
        loadingCheckInRecords: false,
        reminders: List<HomeReminderItemData>.from(state.demoReminders),
        checkInRecords:
            List<HomeCheckInRecordData>.from(state.demoCheckInRecords),
      );
      return;
    }

    if (state.lastRequestedUserId != null &&
        state.lastRequestedUserId != userId) {
      state = state.copyWith(
        reminders: const [],
        checkInRecords: const [],
      );
    }

    if (!force && state.lastRequestedUserId == userId) return;

    state = state.copyWith(lastRequestedUserId: userId);
    unawaited(loadReminders(syncRemote: true));
    unawaited(loadCheckInRecords());
  }

  Future<void> loadReminders({bool syncRemote = false}) async {
    final userId = _currentUserId;
    if (userId.isEmpty) {
      state = state.copyWith(
        loadingReminders: false,
        reminders: List<HomeReminderItemData>.from(state.demoReminders),
      );
      return;
    }

    final requestId = ++_reminderRequestId;
    state = state.copyWith(loadingReminders: true);

    try {
      final localItems = await _gateway.loadTodayItems(userId);
      if (!_canApplyReminderResult(requestId, userId)) return;
      _applyReminderItems(localItems);

      if (syncRemote) {
        await _gateway.syncRemoteToLocal(userId);
        if (!_canApplyReminderResult(requestId, userId)) return;
        final refreshedItems = await _gateway.loadTodayItems(userId);
        if (!_canApplyReminderResult(requestId, userId)) return;
        _applyReminderItems(refreshedItems);
      }
    } catch (e) {
      debugPrint('[home] loadTodayReminders failed: $e');
      if (_canApplyReminderResult(requestId, userId)) {
        state = state.copyWith(reminders: const []);
      }
    } finally {
      if (_isActiveReminderRequest(requestId)) {
        state = state.copyWith(loadingReminders: false);
      }
    }
  }

  Future<void> loadCheckInRecords() async {
    if (state.loadingCheckInRecords) {
      _checkInReloadQueued = true;
      return;
    }

    final userId = _currentUserId;
    if (userId.isEmpty) {
      _checkInReloadQueued = false;
      state = state.copyWith(
        loadingCheckInRecords: false,
        checkInRecords:
            List<HomeCheckInRecordData>.from(state.demoCheckInRecords),
      );
      return;
    }

    final requestId = ++_checkInRequestId;
    state = state.copyWith(loadingCheckInRecords: true);

    try {
      final records = await _gateway.loadCheckInRecords(
        userId,
        maxDays: 7,
        maxItems: 160,
      );
      if (!_canApplyCheckInResult(requestId, userId)) return;
      state = state.copyWith(
        checkInRecords: List<HomeCheckInRecordData>.from(records),
      );
    } catch (e) {
      debugPrint('[home] loadCheckInRecords failed: $e');
      if (_canApplyCheckInResult(requestId, userId)) {
        state = state.copyWith(checkInRecords: const []);
      }
    } finally {
      if (_isActiveCheckInRequest(requestId)) {
        state = state.copyWith(loadingCheckInRecords: false);
      }
      if (_isActiveCheckInRequest(requestId) && _checkInReloadQueued) {
        _checkInReloadQueued = false;
        unawaited(loadCheckInRecords());
      }
    }
  }

  void cycleHealthTip() {
    final tips = state.healthTips;
    if (tips.length <= 1) return;

    final currentTip = state.todayTip;
    final nextTips = tips.where((tip) => tip != currentTip).toList();
    if (nextTips.isEmpty) return;

    state = state.copyWith(
      todayTip: nextTips[Random().nextInt(nextTips.length)],
    );
  }

  void updateTodayTip(String nextTip) {
    if (nextTip == state.todayTip) return;
    state = state.copyWith(todayTip: nextTip);
  }

  void _bindRevision(String userId) {
    _revisionSubscription?.cancel();
    final scopedUserId = userId.trim();
    if (scopedUserId.isEmpty) return;

    _revisionSubscription =
        _gateway.watchRevision(scopedUserId).listen((_) {
      unawaited(loadReminders());
      unawaited(loadCheckInRecords());
    });
  }

  void _applyReminderItems(List<ReminderItem> items) {
    state = state.copyWith(
      reminders: items.map(_mapReminderItem).toList(growable: false),
    );
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
    return _isActiveReminderRequest(requestId) && userId == _currentUserId;
  }

  bool _isActiveReminderRequest(int requestId) {
    return requestId == _reminderRequestId;
  }

  bool _canApplyCheckInResult(int requestId, String userId) {
    return _isActiveCheckInRequest(requestId) && userId == _currentUserId;
  }

  bool _isActiveCheckInRequest(int requestId) {
    return requestId == _checkInRequestId;
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});

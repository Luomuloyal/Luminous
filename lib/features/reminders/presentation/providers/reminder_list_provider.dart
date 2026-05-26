import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/utils/message_utils.dart';

/// Reminders 模块 ReminderLocalGateway 注入 provider。
final reminderListGatewayProvider = Provider<ReminderLocalGateway>(
  (ref) => reminderLocalGateway,
);

/// 提醒列表页状态。
class ReminderListState {
  const ReminderListState({
    this.items = const [],
    this.loading = false,
    this.syncing = false,
    this.error,
    this.busyReminderIds = const {},
    this.isClosed = false,
  });

  final List<ReminderPlan> items;
  final bool loading;
  final bool syncing;
  final String? error;
  final Set<String> busyReminderIds;
  final bool isClosed;

  bool get isLoading => loading || syncing;

  ReminderListState copyWith({
    List<ReminderPlan>? items,
    bool? loading,
    bool? syncing,
    String? error,
    Set<String>? busyReminderIds,
    bool? isClosed,
  }) {
    return ReminderListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      syncing: syncing ?? this.syncing,
      error: error ?? this.error,
      busyReminderIds: busyReminderIds ?? this.busyReminderIds,
      isClosed: isClosed ?? this.isClosed,
    );
  }
}

/// 提醒列表页状态管理器。
class ReminderListNotifier extends Notifier<ReminderListState> {
  ReminderLocalGateway get _gateway => ref.read(reminderListGatewayProvider);

  StreamSubscription<int>? _revisionSubscription;
  bool _reloadQueued = false;
  bool _syncQueued = false;
  int _loadRequestId = 0;

  String get _userId => ref.read(currentUserProvider)?.id ?? '';
  bool get _isLoggedIn =>
      (ref.read(currentUserProvider)?.hasData ?? false) &&
      _userId.trim().isNotEmpty;

  @override
  ReminderListState build() {
    ref.onDispose(() {
      _revisionSubscription?.cancel();
    });

    ref.listen(currentUserProvider, (prev, next) {
      _handleUserChanged();
    });

    Future.microtask(() {
      if (!state.isClosed) _handleUserChanged();
    });

    return const ReminderListState();
  }

  // ── 核心操作 ──

  Future<void> load() async {
    final scopedUserId = _userId.trim();
    if (scopedUserId.isEmpty) {
      state = state.copyWith(
        items: const [],
        error: null,
        loading: false,
        busyReminderIds: const {},
      );
      _reloadQueued = false;
      return;
    }

    if (state.loading) {
      _reloadQueued = true;
      return;
    }

    final requestId = ++_loadRequestId;
    state = state.copyWith(loading: true);

    try {
      final items = await _gateway.loadPlans(scopedUserId);
      if (!_canApplyLoadResult(requestId, scopedUserId)) return;
      state = state.copyWith(items: _sortedPlans(items), error: null);
    } catch (error) {
      if (!_canApplyLoadResult(requestId, scopedUserId)) return;
      state = state.copyWith(
        error: MessageUtils.extractError(error),
        items: const [],
      );
    } finally {
      if (_isActiveLoadRequest(requestId) && !state.isClosed) {
        state = state.copyWith(loading: false);
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued && !state.isClosed) {
        _reloadQueued = false;
        unawaited(load());
      }
    }
  }

  /// 返回错误消息供 page 层 toast。
  Future<String?> sync() async {
    final scopedUserId = _userId.trim();
    if (scopedUserId.isEmpty) return null;

    if (state.syncing) {
      _syncQueued = true;
      return null;
    }

    state = state.copyWith(syncing: true, error: null);

    try {
      await _gateway.syncRemoteToLocal(scopedUserId);
      if (!state.isClosed && scopedUserId == _userId.trim()) {
        await load();
      }
    } catch (error) {
      if (!state.isClosed && scopedUserId == _userId.trim()) {
        final msg = MessageUtils.extractError(error);
        state = state.copyWith(error: msg);
        return msg;
      }
    } finally {
      if (!state.isClosed && scopedUserId == _userId.trim()) {
        state = state.copyWith(syncing: false);
      }
      if (_syncQueued && !state.isClosed && scopedUserId == _userId.trim()) {
        _syncQueued = false;
        unawaited(sync());
      }
    }
    return null;
  }

  Future<void> applySavedPlan(ReminderPlan plan) async {
    final scopedUserId = _userId.trim();
    if (scopedUserId.isEmpty) return;
    final planUserId = plan.userId.trim();
    if (planUserId.isNotEmpty && planUserId != scopedUserId) {
      await sync();
      return;
    }
    await _gateway.upsertLocalPlan(scopedUserId, plan);
    if (!state.isClosed) await load();
  }

  /// 返回错误消息供 page 层 toast。
  Future<String?> toggleEnabled(ReminderPlan plan, bool enabled) async {
    return _runWithBusyReminder(plan.id, () async {
      final scopedUserId = _userId.trim();
      if (scopedUserId.isEmpty) return null;
      try {
        final next = await ReminderApi.upsert(
          userId: scopedUserId,
          id: plan.id,
          time: plan.time,
          drugCode: plan.drugCode,
          approvalNo: plan.approvalNo,
          productName: plan.productName,
          medicines: plan.medicines,
          dosage: plan.dosage,
          subtitle: plan.subtitle,
          enabled: enabled,
          repeatRule: plan.repeatRule,
          method: plan.method,
          startDate: plan.startDate,
          endDate: plan.endDate,
        );
        if (state.isClosed) return null;
        await _gateway.upsertLocalPlan(scopedUserId, next.result);
        if (!state.isClosed) await load();
      } catch (error) {
        if (!state.isClosed) return MessageUtils.extractError(error);
      }
      return null;
    });
  }

  /// 返回 null=成功，非空=错误消息。
  Future<String?> deletePlan(ReminderPlan plan) async {
    return _runWithBusyReminder(plan.id, () async {
      final scopedUserId = _userId.trim();
      if (scopedUserId.isEmpty) return null;
      try {
        await ReminderApi.delete(userId: scopedUserId, id: plan.id);
        if (state.isClosed) return null;
        await _gateway.deleteLocalPlan(scopedUserId, plan.id);
        if (!state.isClosed) await load();
        return null; // 成功
      } catch (error) {
        if (!state.isClosed) return MessageUtils.extractError(error);
      }
      return null;
    });
  }

  bool isBusy(String reminderId) {
    return state.busyReminderIds.contains(reminderId.trim());
  }

  // ── 内部 ──

  void _handleUserChanged() {
    _bindRevision();
    if (_isLoggedIn) {
      unawaited(_loadThenSync());
      return;
    }
    unawaited(load());
  }

  Future<void> _loadThenSync() async {
    await load();
    if (!state.isClosed && _isLoggedIn) {
      await sync();
    }
  }

  void _bindRevision() {
    _revisionSubscription?.cancel();
    final scopedUserId = _userId.trim();
    if (scopedUserId.isEmpty) return;
    _revisionSubscription = _gateway.watchRevision(scopedUserId).listen((_) {
      if (!state.isClosed) unawaited(load());
    });
  }

  Future<String?> _runWithBusyReminder(
    String reminderId,
    Future<String?> Function() task,
  ) async {
    final normalizedId = reminderId.trim();
    if (normalizedId.isEmpty) return task();
    if (state.busyReminderIds.contains(normalizedId)) return null;

    state = state.copyWith(
      busyReminderIds: {...state.busyReminderIds, normalizedId},
    );
    try {
      return await task();
    } finally {
      if (!state.isClosed) {
        state = state.copyWith(
          busyReminderIds: state.busyReminderIds.difference({normalizedId}),
        );
      }
    }
  }

  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) {
    return List<ReminderPlan>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return !state.isClosed &&
        _isActiveLoadRequest(requestId) &&
        scopedUserId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }
}

final reminderListProvider = NotifierProvider<ReminderListNotifier,
    ReminderListState>(() {
  return ReminderListNotifier();
});

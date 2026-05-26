import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/features/auth/providers/user_session_provider.dart';
import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';
import 'package:luminous/utils/message_utils.dart';

final reminderListGatewayProvider = Provider<ReminderLocalGateway>(
  (ref) => reminderLocalGateway,
);

class ReminderListState {
  const ReminderListState({
    this.items = const [],
    this.loading = false,
    this.syncing = false,
    this.error,
    this.busyReminderIds = const {},
  });

  final List<ReminderPlan> items;
  final bool loading;
  final bool syncing;
  final String? error;
  final Set<String> busyReminderIds;

  bool get isLoading => loading || syncing;

  ReminderListState copyWith({
    List<ReminderPlan>? items,
    bool? loading,
    bool? syncing,
    String? error,
    Set<String>? busyReminderIds,
  }) {
    return ReminderListState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      syncing: syncing ?? this.syncing,
      error: error ?? this.error,
      busyReminderIds: busyReminderIds ?? this.busyReminderIds,
    );
  }
}

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

    Future.microtask(() => _handleUserChanged());

    return const ReminderListState();
  }

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
      if (_isActiveLoadRequest(requestId)) {
        state = state.copyWith(loading: false);
      }
      if (_isActiveLoadRequest(requestId) && _reloadQueued) {
        _reloadQueued = false;
        unawaited(load());
      }
    }
  }

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
      if (scopedUserId == _userId.trim()) {
        await load();
      }
    } catch (error) {
      if (scopedUserId == _userId.trim()) {
        final msg = MessageUtils.extractError(error);
        state = state.copyWith(error: msg);
        return msg;
      }
    } finally {
      if (scopedUserId == _userId.trim()) {
        state = state.copyWith(syncing: false);
      }
      if (_syncQueued && scopedUserId == _userId.trim()) {
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
    await load();
  }

  Future<String?> toggleEnabled(ReminderPlan plan, bool enabled) async {
    return _runWithBusyReminder(plan.id, () async {
      final scopedUserId = _userId.trim();
      if (scopedUserId.isEmpty) return null;
      try {
        final next = await ReminderApi.upsert(
          userId: scopedUserId, id: plan.id, time: plan.time,
          drugCode: plan.drugCode, approvalNo: plan.approvalNo,
          productName: plan.productName, medicines: plan.medicines,
          dosage: plan.dosage, subtitle: plan.subtitle,
          enabled: enabled, repeatRule: plan.repeatRule,
          method: plan.method, startDate: plan.startDate,
          endDate: plan.endDate,
        );
        await _gateway.upsertLocalPlan(scopedUserId, next.result);
        await load();
      } catch (error) {
        return MessageUtils.extractError(error);
      }
      return null;
    });
  }

  Future<String?> deletePlan(ReminderPlan plan) async {
    return _runWithBusyReminder(plan.id, () async {
      final scopedUserId = _userId.trim();
      if (scopedUserId.isEmpty) return null;
      try {
        await ReminderApi.delete(userId: scopedUserId, id: plan.id);
        await _gateway.deleteLocalPlan(scopedUserId, plan.id);
        await load();
        return null;
      } catch (error) {
        return MessageUtils.extractError(error);
      }
    });
  }

  bool isBusy(String reminderId) {
    return state.busyReminderIds.contains(reminderId.trim());
  }

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
    if (_isLoggedIn) await sync();
  }

  void _bindRevision() {
    _revisionSubscription?.cancel();
    final scopedUserId = _userId.trim();
    if (scopedUserId.isEmpty) return;
    _revisionSubscription = _gateway.watchRevision(scopedUserId).listen((_) {
      unawaited(load());
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
      state = state.copyWith(
        busyReminderIds: state.busyReminderIds.difference({normalizedId}),
      );
    }
  }

  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) {
    return List<ReminderPlan>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  bool _canApplyLoadResult(int requestId, String scopedUserId) {
    return _isActiveLoadRequest(requestId) && scopedUserId == _userId.trim();
  }

  bool _isActiveLoadRequest(int requestId) {
    return requestId == _loadRequestId;
  }
}

final reminderListProvider = NotifierProvider<ReminderListNotifier,
    ReminderListState>(() {
  return ReminderListNotifier();
});

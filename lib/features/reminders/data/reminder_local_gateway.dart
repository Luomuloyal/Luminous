import 'dart:async';

import 'package:luminous/api/reminder_api.dart';
import 'package:luminous/features/reminders/data/reminder_local_store.dart';
import 'package:luminous/features/reminders/data/today_reminder_local_store.dart';
import 'package:luminous/features/reminders/data/today_reminder_store.dart';
import 'package:luminous/utils/notification_service.dart';
import 'package:luminous/utils/dio_request.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

typedef FetchRemoteReminderPlans =
    Future<ApiResult<ReminderListResult>> Function({required String userId});
typedef RescheduleReminderNotifications =
    Future<void> Function(List<ReminderPlan> plans);
typedef CancelReminderNotifications = Future<void> Function();

abstract interface class ReminderLocalGateway {
  Future<List<ReminderPlan>> loadPlans(String userId);

  Future<List<ReminderItem>> loadTodayItems(String userId);

  Stream<int> watchRevision(String userId);

  Future<void> syncRemoteToLocal(String userId);

  Future<void> rescheduleFromLocal(String userId);

  Future<void> upsertLocalPlan(String userId, ReminderPlan plan);

  Future<void> deleteLocalPlan(String userId, String reminderId);

  Future<void> markTodayDone({
    required String userId,
    required ReminderItem item,
    int? takenAt,
  });

  Future<void> markTodayUndone({
    required String userId,
    required String reminderId,
  });

  Future<List<HomeCheckInRecordData>> loadCheckInRecords(
    String userId, {
    int maxDays,
    int maxItems,
  });
}

class ReminderLocalGatewayImpl implements ReminderLocalGateway {
  ReminderLocalGatewayImpl({
    ReminderLocalStore? reminderStore,
    TodayReminderStore? todayReminderStore,
    FetchRemoteReminderPlans? fetchRemotePlans,
    RescheduleReminderNotifications? rescheduleNotifications,
    CancelReminderNotifications? cancelNotifications,
  }) : _reminderStore = reminderStore ?? reminderLocalStore,
       _todayReminderStore = todayReminderStore ?? todayReminderLocalStore,
       _fetchRemotePlans = fetchRemotePlans ?? ReminderApi.list,
       _rescheduleNotifications =
           rescheduleNotifications ??
           NotificationService.instance.rescheduleAll,
       _cancelNotifications =
           cancelNotifications ?? NotificationService.instance.cancelAll;

  final ReminderLocalStore _reminderStore;
  final TodayReminderStore _todayReminderStore;
  final FetchRemoteReminderPlans _fetchRemotePlans;
  final RescheduleReminderNotifications _rescheduleNotifications;
  final CancelReminderNotifications _cancelNotifications;
  final StreamController<_ReminderRevisionEvent> _revisionController =
      StreamController<_ReminderRevisionEvent>.broadcast();
  final Map<String, int> _revisions = <String, int>{};

  @override
  Future<List<ReminderPlan>> loadPlans(String userId) {
    return _reminderStore.loadForUser(userId);
  }

  @override
  Future<List<ReminderItem>> loadTodayItems(String userId) {
    return _todayReminderStore.loadTodaySnapshotItems(userId);
  }

  @override
  Stream<int> watchRevision(String userId) {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return const Stream<int>.empty();
    }
    return _revisionController.stream
        .where((event) => event.userId == uid)
        .map((event) => event.revision);
  }

  @override
  Future<void> syncRemoteToLocal(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      await _cancelNotifications();
      return;
    }

    final response = await _fetchRemotePlans(userId: uid);
    final items = _sortedPlans(response.result.items);
    await _replacePlansAndNotify(uid, items);
  }

  @override
  Future<void> rescheduleFromLocal(String userId) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      await _cancelNotifications();
      return;
    }

    final plans = await loadPlans(uid);
    await _replaceTodaySnapshotFromPlans(uid, plans);
    await _rescheduleNotifications(plans);
    _emitRevision(uid);
  }

  @override
  Future<void> upsertLocalPlan(String userId, ReminderPlan plan) async {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return;
    }
    final nextItems = List<ReminderPlan>.from(await loadPlans(uid))
      ..removeWhere((item) => item.id == plan.id)
      ..add(plan);
    await _replacePlansAndNotify(uid, nextItems);
  }

  @override
  Future<void> deleteLocalPlan(String userId, String reminderId) async {
    final uid = userId.trim();
    final normalizedId = reminderId.trim();
    if (uid.isEmpty || normalizedId.isEmpty) {
      return;
    }
    final current = await loadPlans(uid);
    final nextItems = current
        .where((item) => item.id.trim() != normalizedId)
        .toList(growable: false);
    await _replacePlansAndNotify(uid, nextItems);
  }

  @override
  Future<void> markTodayDone({
    required String userId,
    required ReminderItem item,
    int? takenAt,
  }) async {
    final uid = userId.trim();
    final reminderId = item.id.trim();
    if (uid.isEmpty || reminderId.isEmpty) {
      return;
    }
    final timestamp = takenAt ?? DateTime.now().millisecondsSinceEpoch;
    await _todayReminderStore.replaceTodayCheckin(
      userId: uid,
      reminderId: reminderId,
      takenAt: timestamp,
    );
    await _todayReminderStore.saveTodayOverride(
      userId: uid,
      reminderId: reminderId,
      done: true,
    );
    _emitRevision(uid);
  }

  @override
  Future<void> markTodayUndone({
    required String userId,
    required String reminderId,
  }) async {
    final uid = userId.trim();
    final normalizedId = reminderId.trim();
    if (uid.isEmpty || normalizedId.isEmpty) {
      return;
    }
    await _todayReminderStore.deleteTodayCheckin(
      userId: uid,
      reminderId: normalizedId,
    );
    await _todayReminderStore.saveTodayOverride(
      userId: uid,
      reminderId: normalizedId,
      done: false,
    );
    _emitRevision(uid);
  }

  @override
  Future<List<HomeCheckInRecordData>> loadCheckInRecords(
    String userId, {
    int maxDays = 7,
    int maxItems = 120,
  }) {
    final uid = userId.trim();
    if (uid.isEmpty) {
      return Future.value(const <HomeCheckInRecordData>[]);
    }
    return _todayReminderStore.loadRecentCheckinRecords(
      uid,
      maxDays: maxDays,
      maxItems: maxItems,
    );
  }

  Future<void> _replacePlansAndNotify(
    String userId,
    List<ReminderPlan> plans,
  ) async {
    final sorted = _sortedPlans(plans);
    await _reminderStore.replaceForUser(userId, sorted);
    await _replaceTodaySnapshotFromPlans(userId, sorted);
    await _rescheduleNotifications(sorted);
    _emitRevision(userId);
  }

  Future<void> _replaceTodaySnapshotFromPlans(
    String userId,
    List<ReminderPlan> plans,
  ) async {
    final items = await _todayReminderStore.buildTodayItemsFromPlans(
      userId,
      plans,
    );
    await _todayReminderStore.replaceTodaySnapshot(
      userId: userId,
      items: items,
    );
  }

  List<ReminderPlan> _sortedPlans(Iterable<ReminderPlan> items) {
    return List<ReminderPlan>.from(items)
      ..sort((a, b) => a.time.compareTo(b.time));
  }

  void _emitRevision(String userId) {
    final uid = userId.trim();
    if (uid.isEmpty || _revisionController.isClosed) {
      return;
    }
    final nextRevision = (_revisions[uid] ?? 0) + 1;
    _revisions[uid] = nextRevision;
    _revisionController.add(
      _ReminderRevisionEvent(userId: uid, revision: nextRevision),
    );
  }
}

class _ReminderRevisionEvent {
  const _ReminderRevisionEvent({required this.userId, required this.revision});

  final String userId;
  final int revision;
}

final ReminderLocalGateway reminderLocalGateway = ReminderLocalGatewayImpl();

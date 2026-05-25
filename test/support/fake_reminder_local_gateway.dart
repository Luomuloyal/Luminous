import 'dart:async';

import 'package:luminous/features/reminders/data/reminder_local_gateway.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

class FakeReminderLocalGateway implements ReminderLocalGateway {
  final Map<String, List<ReminderPlan>> _plansByUser =
      <String, List<ReminderPlan>>{};
  final Map<String, List<ReminderItem>> _todayItemsByUser =
      <String, List<ReminderItem>>{};
  final Map<String, List<HomeCheckInRecordData>> _checkInRecordsByUser =
      <String, List<HomeCheckInRecordData>>{};
  final StreamController<_RevisionEvent> _revisionController =
      StreamController<_RevisionEvent>.broadcast();
  final Map<String, int> _revisions = <String, int>{};

  int loadPlansCalls = 0;
  int loadTodayItemsCalls = 0;
  int syncRemoteToLocalCalls = 0;
  int rescheduleFromLocalCalls = 0;
  int loadCheckInRecordsCalls = 0;
  Future<void> Function(String userId)? onSyncRemoteToLocal;
  Future<void> Function(String userId)? onRescheduleFromLocal;

  Future<void> dispose() async {
    await _revisionController.close();
  }

  void setPlans(String userId, List<ReminderPlan> plans) {
    _plansByUser[userId.trim()] = List<ReminderPlan>.from(plans);
  }

  void setTodayItems(String userId, List<ReminderItem> items) {
    _todayItemsByUser[userId.trim()] = List<ReminderItem>.from(items);
  }

  void emitRevision(String userId) {
    final uid = userId.trim();
    final nextRevision = (_revisions[uid] ?? 0) + 1;
    _revisions[uid] = nextRevision;
    _revisionController.add(_RevisionEvent(uid, nextRevision));
  }

  void setCheckInRecords(String userId, List<HomeCheckInRecordData> records) {
    _checkInRecordsByUser[userId.trim()] = List<HomeCheckInRecordData>.from(
      records,
    );
  }

  @override
  Future<List<ReminderPlan>> loadPlans(String userId) async {
    loadPlansCalls += 1;
    return List<ReminderPlan>.from(_plansByUser[userId.trim()] ?? const []);
  }

  @override
  Future<List<ReminderItem>> loadTodayItems(String userId) async {
    loadTodayItemsCalls += 1;
    return List<ReminderItem>.from(
      _todayItemsByUser[userId.trim()] ?? const <ReminderItem>[],
    );
  }

  @override
  Stream<int> watchRevision(String userId) {
    final uid = userId.trim();
    return _revisionController.stream
        .where((event) => event.userId == uid)
        .map((event) => event.revision);
  }

  @override
  Future<void> syncRemoteToLocal(String userId) async {
    syncRemoteToLocalCalls += 1;
    final callback = onSyncRemoteToLocal;
    if (callback != null) {
      await callback(userId.trim());
    }
  }

  @override
  Future<void> rescheduleFromLocal(String userId) async {
    rescheduleFromLocalCalls += 1;
    final callback = onRescheduleFromLocal;
    if (callback != null) {
      await callback(userId.trim());
    }
    emitRevision(userId);
  }

  @override
  Future<void> upsertLocalPlan(String userId, ReminderPlan plan) async {
    final uid = userId.trim();
    final next = List<ReminderPlan>.from(_plansByUser[uid] ?? const []);
    next.removeWhere((item) => item.id == plan.id);
    next.add(plan);
    next.sort((a, b) => a.time.compareTo(b.time));
    _plansByUser[uid] = next;
    emitRevision(uid);
  }

  @override
  Future<void> deleteLocalPlan(String userId, String reminderId) async {
    final uid = userId.trim();
    final next = List<ReminderPlan>.from(_plansByUser[uid] ?? const [])
      ..removeWhere((item) => item.id == reminderId.trim());
    _plansByUser[uid] = next;
    emitRevision(uid);
  }

  @override
  Future<void> markTodayDone({
    required String userId,
    required ReminderItem item,
    int? takenAt,
  }) async {
    final uid = userId.trim();
    _todayItemsByUser[uid] = (await loadTodayItems(uid))
        .map(
          (entry) => entry.id == item.id
              ? ReminderItem(
                  id: entry.id,
                  time: entry.time,
                  title: entry.title,
                  dosage: entry.dosage,
                  subtitle: entry.subtitle,
                  done: true,
                )
              : entry,
        )
        .toList(growable: false);
    emitRevision(uid);
  }

  @override
  Future<void> markTodayUndone({
    required String userId,
    required String reminderId,
  }) async {
    final uid = userId.trim();
    final normalizedId = reminderId.trim();
    _todayItemsByUser[uid] = (await loadTodayItems(uid))
        .map(
          (entry) => entry.id == normalizedId
              ? ReminderItem(
                  id: entry.id,
                  time: entry.time,
                  title: entry.title,
                  dosage: entry.dosage,
                  subtitle: entry.subtitle,
                  done: false,
                )
              : entry,
        )
        .toList(growable: false);
    emitRevision(uid);
  }

  @override
  Future<List<HomeCheckInRecordData>> loadCheckInRecords(
    String userId, {
    int maxDays = 7,
    int maxItems = 120,
  }) async {
    loadCheckInRecordsCalls += 1;
    return List<HomeCheckInRecordData>.from(
      _checkInRecordsByUser[userId.trim()] ?? const <HomeCheckInRecordData>[],
    );
  }
}

class _RevisionEvent {
  const _RevisionEvent(this.userId, this.revision);

  final String userId;
  final int revision;
}

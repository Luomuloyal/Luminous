import 'package:luminous/features/reminders/data/today_reminder_local_store.dart';
import 'package:luminous/features/reminders/data/today_reminder_store.dart';
import 'package:luminous/shared/models/home.dart';
import 'package:luminous/features/reminders/presentation/models/reminder.dart';

class FakeTodayReminderStore implements TodayReminderStore {
  FakeTodayReminderStore({
    List<ReminderItem> initialSnapshot = const [],
    Map<String, bool> initialOverrides = const {},
    Set<String> initialDoneIds = const {},
    String? dateKey,
  }) : _snapshot = List<ReminderItem>.from(initialSnapshot),
       _overrides = Map<String, bool>.from(initialOverrides),
       _doneIds = Set<String>.from(initialDoneIds),
       _dateKey = dateKey ?? todayReminderLocalStore.todayRange().dateKey;

  final String _dateKey;
  List<ReminderItem> _snapshot;
  final Map<String, bool> _overrides;
  final Set<String> _doneIds;

  int replaceTodaySnapshotCalls = 0;
  int loadTodaySnapshotItemsCalls = 0;
  String? lastReplaceUserId;
  String? lastReplaceDate;
  final List<String> deletedReminderIds = <String>[];

  List<ReminderItem> get snapshot => List<ReminderItem>.unmodifiable(_snapshot);

  Map<String, bool> get savedOverrides =>
      Map<String, bool>.unmodifiable(_overrides);

  @override
  ({int start, int end, String dateKey}) todayRange() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final end = start + const Duration(days: 1).inMilliseconds;
    return (start: start, end: end, dateKey: _dateKey);
  }

  @override
  String resolveDateKey([String? date]) {
    final trimmed = (date ?? '').trim();
    return trimmed.isEmpty ? _dateKey : trimmed;
  }

  @override
  Future<void> replaceTodaySnapshot({
    required String? userId,
    String? date,
    required List<ReminderItem> items,
  }) async {
    replaceTodaySnapshotCalls += 1;
    lastReplaceUserId = userId;
    lastReplaceDate = resolveDateKey(date);
    _snapshot = items
        .map(
          (item) => ReminderItem(
            id: item.id,
            time: item.time,
            title: item.title,
            subtitle: item.subtitle,
            done: item.done,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<Map<String, bool>> loadTodayOverrides(String? userId) async {
    return Map<String, bool>.from(_overrides);
  }

  @override
  Future<void> saveTodayOverride({
    required String userId,
    required String reminderId,
    required bool done,
  }) async {
    final id = reminderId.trim();
    if (id.isEmpty) {
      return;
    }
    _overrides[id] = done;
  }

  @override
  Future<void> replaceTodayCheckin({
    required String userId,
    required String reminderId,
    String? remoteId,
    required int takenAt,
  }) async {
    final id = reminderId.trim();
    if (id.isEmpty) {
      return;
    }
    _doneIds.add(id);
  }

  @override
  Future<void> deleteTodayCheckin({
    required String userId,
    required String reminderId,
  }) async {
    final id = reminderId.trim();
    if (id.isEmpty) {
      return;
    }
    deletedReminderIds.add(id);
    _doneIds.remove(id);
  }

  @override
  Future<List<ReminderItem>> applyTodayState(
    String? userId, {
    required List<ReminderItem> items,
    Map<String, bool>? overrides,
  }) async {
    final effectiveOverrides = <String, bool>{..._overrides, ...?overrides};

    return items
        .map((item) {
          final reminderId = item.id.trim();
          final override = effectiveOverrides[reminderId];
          final done = override ?? _doneIds.contains(reminderId) || item.done;
          return ReminderItem(
            id: item.id,
            time: item.time,
            title: item.title,
            subtitle: item.subtitle,
            done: done,
          );
        })
        .toList(growable: false);
  }

  @override
  Future<List<ReminderItem>> loadTodaySnapshotItems(
    String? userId, {
    String? date,
    Map<String, bool>? overrides,
  }) async {
    loadTodaySnapshotItemsCalls += 1;
    return applyTodayState(userId, items: _snapshot, overrides: overrides);
  }

  @override
  Future<List<ReminderItem>> buildTodayItemsFromPlans(
    String? userId,
    List<ReminderPlan> plans,
  ) async {
    final items = plans
        .where((plan) => plan.enabled)
        .map(
          (plan) => ReminderItem(
            id: plan.id,
            time: plan.time,
            title: plan.productName,
            subtitle: plan.subtitle,
            dosage: plan.dosage,
            done: false,
          ),
        )
        .toList(growable: false);
    return applyTodayState(userId, items: items);
  }

  @override
  Future<List<HomeCheckInRecordData>> loadRecentCheckinRecords(
    String? userId, {
    int maxDays = 7,
    int maxItems = 120,
  }) async {
    final dayKey = resolveDateKey();
    return (await loadTodaySnapshotItems(userId))
        .map(
          (item) => HomeCheckInRecordData(
            dateKey: dayKey,
            reminderId: item.id,
            title: item.title,
            reminderTime: item.time,
            done: item.done,
            takenAt: item.done ? DateTime.now().millisecondsSinceEpoch : null,
          ),
        )
        .toList(growable: false);
  }
}

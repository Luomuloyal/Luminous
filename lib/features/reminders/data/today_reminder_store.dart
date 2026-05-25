part of 'today_reminder_local_store.dart';

abstract interface class TodayReminderStore {
  ({int start, int end, String dateKey}) todayRange();

  String resolveDateKey([String? date]);

  Future<void> replaceTodaySnapshot({
    required String? userId,
    String? date,
    required List<ReminderItem> items,
  });

  Future<Map<String, bool>> loadTodayOverrides(String? userId);

  Future<void> saveTodayOverride({
    required String userId,
    required String reminderId,
    required bool done,
  });

  Future<void> replaceTodayCheckin({
    required String userId,
    required String reminderId,
    String? remoteId,
    required int takenAt,
  });

  Future<void> deleteTodayCheckin({
    required String userId,
    required String reminderId,
  });

  Future<List<ReminderItem>> loadTodaySnapshotItems(
    String? userId, {
    String? date,
    Map<String, bool>? overrides,
  });

  Future<List<ReminderItem>> applyTodayState(
    String? userId, {
    required List<ReminderItem> items,
    Map<String, bool>? overrides,
  });

  Future<List<ReminderItem>> buildTodayItemsFromPlans(
    String? userId,
    List<ReminderPlan> plans,
  );

  Future<List<HomeCheckInRecordData>> loadRecentCheckinRecords(
    String? userId, {
    int maxDays,
    int maxItems,
  });
}

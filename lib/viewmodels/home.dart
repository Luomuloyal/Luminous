class ReminderItem {
  final String id;
  final String time;
  final String title;
  final String subtitle;
  final bool done;

  const ReminderItem({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      done: json['done'] == true,
    );
  }
}

class TodayRemindersResult {
  final String date;
  final List<ReminderItem> items;

  const TodayRemindersResult({required this.date, required this.items});

  factory TodayRemindersResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems
              .whereType<Map>()
              .map((e) => ReminderItem.fromJson(e.cast<String, dynamic>()))
              .toList()
        : <ReminderItem>[];

    return TodayRemindersResult(
      date: (json['date'] ?? '').toString(),
      items: items,
    );
  }
}

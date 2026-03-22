import 'package:flutter/material.dart';

/// 首页模块相关的数据模型与轻量 UI 小组件。
///
/// 注意：
/// - `ReminderItem/TodayRemindersResult` 用于承载接口返回；
/// - `HomeStatusChip/HomeInfoPill` 是首页顶部卡片复用的小组件。
class ReminderItem {
  /// 提醒 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// 提醒时间（HH:mm）。
  final String time;

  /// 提醒标题（通常是药品名或事项名）。
  final String title;

  /// 提醒副标题（例如服用说明）。
  final String subtitle;

  /// 是否已完成（用于 UI 状态展示）。
  final bool done;

  /// 创建一个提醒条目对象。
  const ReminderItem({
    required this.id,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.done,
  });

  /// 从后端 JSON 反序列化为 `ReminderItem`。
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

/// 首页“今日提醒”区域使用的展示数据。
class HomeReminderItemData {
  /// 提醒左侧图标。
  final IconData icon;

  /// 提醒标题（通常为时间 + 药品名）。
  final String title;

  /// 提醒副标题（服用说明等）。
  final String subtitle;

  /// 当前提醒是否已完成。
  final bool done;

  /// 创建一个首页提醒条目数据对象。
  const HomeReminderItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
  });
}

class TodayRemindersResult {
  /// 数据对应的日期（yyyy-MM-dd）。
  final String date;

  /// 今日提醒列表。
  final List<ReminderItem> items;

  /// 创建一个今日提醒结果对象。
  const TodayRemindersResult({required this.date, required this.items});

  /// 从后端 JSON 反序列化为 `TodayRemindersResult`。
  factory TodayRemindersResult.fromJson(Map<String, dynamic> json) {
    /// 原始 items 字段，类型可能不稳定。
    final rawItems = json['items'];

    /// 解析后的提醒条目列表。
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

/// 首页顶部卡片中的状态 chip（例如“已同步”）。
class HomeStatusChip extends StatelessWidget {
  /// 创建一个状态 chip。
  const HomeStatusChip({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x33FFFFFF),
    this.textColor = Colors.white,
  });

  /// chip 上展示的文本。
  final String text;

  /// chip 背景色。
  final Color backgroundColor;

  /// chip 文字色。
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// 首页顶部卡片中的信息 pill（例如“今日提醒 3 条”）。
class HomeInfoPill extends StatelessWidget {
  /// 创建一个信息 pill。
  const HomeInfoPill({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x29FFFFFF),
    this.textColor = Colors.white,
    this.onTap,
    this.onLongPress,
  });

  /// pill 上展示的文本。
  final String text;

  /// pill 背景色。
  final Color backgroundColor;

  /// pill 文字色。
  final Color textColor;

  /// 点击回调。
  final VoidCallback? onTap;

  /// 长按回调。
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap == null && onLongPress == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999)),
          child: content,
        ),
      ),
    );
  }
}

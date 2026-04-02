import 'package:flutter/material.dart';

/// 首页模块相关的数据模型。
///
/// 仅放置页面与组件共享的数据结构，不包含 Widget 实现。
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

/// 首页“常用功能”入口数据。
class HomeFeatureItemData {
  /// 功能入口的唯一 id（用于点击分发）。
  final String id;

  /// 功能入口标题。
  final String title;

  /// 功能入口副标题。
  final String subtitle;

  /// 功能入口图标。
  final IconData icon;

  /// 功能入口主题色。
  final Color color;

  /// 创建一个“常用功能”入口数据对象。
  const HomeFeatureItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
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

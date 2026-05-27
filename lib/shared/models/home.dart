import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'home.g.dart';

/// 首页模块相关的数据模型。
///
/// 仅放置页面与组件共享的数据结构，不包含 Widget 实现。
@JsonSerializable(createFactory: false)
class ReminderItem {
  /// 提醒 id（后端可能返回 `id` 或 `_id`）。
  final String id;

  /// 提醒时间（HH:mm）。
  final String time;

  /// 提醒标题（通常是药品名或事项名）。
  final String title;

  /// 提醒副标题（例如服用说明）。
  final String subtitle;

  /// 服用剂量（例如 1 粒 / 5 ml）。
  final String dosage;

  /// 是否已完成（用于 UI 状态展示）。
  final bool done;

  /// 创建一个提醒条目对象。
  const ReminderItem({
    required this.id,
    required this.time,
    required this.title,
    this.dosage = '',
    required this.subtitle,
    required this.done,
  });

  /// 从后端 JSON 反序列化为 `ReminderItem`。
  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    return ReminderItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      time: (json['time'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      dosage: (json['dosage'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      done: _parseTruthy(json['done']),
    );
  }

  Map<String, dynamic> toJson() => _$ReminderItemToJson(this);

  /// Backend may return booleans, ints, or strings for truthy fields.
  static bool _parseTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lowered = value.toLowerCase().trim();
      return lowered == 'true' || lowered == 'yes' || lowered == '1';
    }
    return false;
  }
}

/// 首页"常用功能"入口数据。
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

  /// 创建一个"常用功能"入口数据对象。
  const HomeFeatureItemData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

/// 首页"今日提醒"区域使用的展示数据。
class HomeReminderItemData {
  /// 提醒左侧图标。
  final IconData icon;

  /// 提醒标题（通常为时间 + 药品名）。
  final String title;

  /// 提醒副标题（服用说明等）。
  final String subtitle;

  /// 服用剂量。
  final String dosage;

  /// 当前提醒是否已完成。
  final bool done;

  /// 创建一个首页提醒条目数据对象。
  const HomeReminderItemData({
    required this.icon,
    required this.title,
    this.dosage = '',
    required this.subtitle,
    required this.done,
  });
}

/// 首页"打卡记录"区域使用的展示数据。
class HomeCheckInRecordData {
  /// 对应日期键（yyyy-MM-dd）。
  final String dateKey;

  /// 对应提醒 id。
  final String reminderId;

  /// 提醒标题（药名或事项名）。
  final String title;

  /// 计划提醒时间（HH:mm，可为空）。
  final String reminderTime;

  /// 当天该条是否已打卡。
  final bool done;

  /// 实际打卡时间戳（毫秒，未打卡时为空）。
  final int? takenAt;

  /// 创建一个首页打卡记录对象。
  const HomeCheckInRecordData({
    required this.dateKey,
    required this.reminderId,
    required this.title,
    required this.reminderTime,
    required this.done,
    this.takenAt,
  });
}

@JsonSerializable(createFactory: false, createToJson: false)
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

  Map<String, dynamic> toJson() => <String, dynamic>{
        'date': date,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

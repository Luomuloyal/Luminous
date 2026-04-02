import 'package:flutter/material.dart';

/// 我的页（Mine）相关的小型展示模型。
class MineQuickActionData {
  /// 创建一个快捷操作数据对象。
  const MineQuickActionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.id,
  });

  /// 快捷操作图标。
  final IconData icon;

  /// 快捷操作标题。
  final String title;

  /// 快捷操作副标题。
  final String subtitle;

  /// 快捷操作主色。
  final Color color;

  /// 快捷操作唯一标识。
  ///
  /// 页面通常会根据它决定点击后执行什么逻辑。
  final String id;
}

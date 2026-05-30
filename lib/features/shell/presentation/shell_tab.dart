import 'package:flutter/material.dart';

enum ShellTab {
  today(Icons.home_outlined, Icons.home, '今日'),
  record(Icons.edit_calendar_outlined, Icons.edit_calendar, '记录'),
  medicine(Icons.medication_outlined, Icons.medication, '用药'),
  mine(Icons.person_outline, Icons.person, '我的'),
  more(Icons.more_horiz, Icons.more_horiz, '更多');

  const ShellTab(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

import 'package:flutter/material.dart';
import 'package:luminous/l10n/app_localizations.dart';

enum ShellTab {
  today(Icons.home_outlined, Icons.home),
  record(Icons.edit_calendar_outlined, Icons.edit_calendar),
  medicine(Icons.medication_outlined, Icons.medication),
  mine(Icons.person_outline, Icons.person),
  more(Icons.more_horiz, Icons.more_horiz);

  const ShellTab(this.icon, this.activeIcon);

  final IconData icon;
  final IconData activeIcon;

  String label(AppLocalizations? l10n) {
    return switch (this) {
      ShellTab.today => l10n?.tabToday ?? 'Today',
      ShellTab.record => l10n?.tabRecord ?? 'Record',
      ShellTab.medicine => l10n?.tabMedicine ?? 'Medicine',
      ShellTab.mine => l10n?.tabMine ?? 'Mine',
      ShellTab.more => l10n?.tabMore ?? 'More',
    };
  }
}

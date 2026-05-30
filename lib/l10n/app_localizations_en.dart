// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Luminous';

  @override
  String get tabToday => 'Today';

  @override
  String get tabRecord => 'Record';

  @override
  String get tabMedicine => 'Medicine';

  @override
  String get tabMine => 'Mine';

  @override
  String get tabMore => 'More';

  @override
  String get todayHeroTitle => 'Today';

  @override
  String get todayHeroDescription =>
      'The new home starts here: we are rebuilding the responsive visual system first, then layering in water tracking, reminders, health snapshots, and Lumi guidance.';

  @override
  String get todayChipWater => 'Water Tracking';

  @override
  String get todayChipMedication => 'Medication Reminders';

  @override
  String get todayChipSnapshot => 'Health Snapshot';

  @override
  String get todayChipDiet => 'Diet Suggestions';

  @override
  String get todayChipEnvironment => 'Environment Alerts';

  @override
  String get todayChipLumi => 'Lumi Guidance';

  @override
  String placeholderSoon(String label) {
    return '$label · Coming Soon';
  }

  @override
  String get placeholderDescription =>
      'This area is reserved structurally and will be rebuilt with the new multi-platform design system.';
}

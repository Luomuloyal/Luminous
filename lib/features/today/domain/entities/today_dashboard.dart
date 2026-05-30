enum TodayDayMoment { morning, afternoon, evening }

enum TodayMedicationKind { atorvastatin }

enum TodayVitalType { heartRate, bloodPressure, sleep }

enum TodayMealSuggestionType { highProteinBalancedLunch }

enum TodayEnvironmentSignalType { pollen, uv }

enum TodayEnvironmentLevel { low, medium, high }

enum TodayLumiSuggestionType { pollenProtection }

class TodayDashboard {
  const TodayDashboard({
    required this.user,
    required this.water,
    required this.medication,
    required this.vitals,
    required this.mealSuggestion,
    required this.environment,
    required this.lumiSuggestion,
  });

  final TodayUserSnapshot user;
  final TodayWaterSummary water;
  final TodayMedicationSummary medication;
  final List<TodayVitalSummary> vitals;
  final TodayMealSuggestion mealSuggestion;
  final TodayEnvironmentSummary environment;
  final TodayLumiSuggestion lumiSuggestion;
}

class TodayUserSnapshot {
  const TodayUserSnapshot({
    required this.moment,
    required this.hasUnreadNotifications,
  });

  final TodayDayMoment moment;
  final bool hasUnreadNotifications;
}

class TodayWaterSummary {
  const TodayWaterSummary({
    required this.completedCount,
    required this.targetCount,
  }) : assert(targetCount > 0);

  final int completedCount;
  final int targetCount;

  int get remainingCount {
    final remaining = targetCount - completedCount;
    return remaining < 0 ? 0 : remaining;
  }

  double get progress {
    final ratio = completedCount / targetCount;
    return ratio.clamp(0, 1).toDouble();
  }
}

class TodayMedicationSummary {
  const TodayMedicationSummary({
    required this.medicineCount,
    required this.pendingCount,
    required this.nextDoseTimeLabel,
    required this.nextMedicine,
  });

  final int medicineCount;
  final int pendingCount;
  final String nextDoseTimeLabel;
  final TodayMedicationKind nextMedicine;
}

class TodayVitalSummary {
  const TodayVitalSummary({required this.type, required this.valueLabel});

  final TodayVitalType type;
  final String valueLabel;
}

class TodayMealSuggestion {
  const TodayMealSuggestion({required this.type});

  final TodayMealSuggestionType type;
}

class TodayEnvironmentSummary {
  const TodayEnvironmentSummary({required this.signals});

  final List<TodayEnvironmentSignal> signals;
}

class TodayEnvironmentSignal {
  const TodayEnvironmentSignal({required this.type, required this.level});

  final TodayEnvironmentSignalType type;
  final TodayEnvironmentLevel level;
}

class TodayLumiSuggestion {
  const TodayLumiSuggestion({required this.type});

  final TodayLumiSuggestionType type;
}

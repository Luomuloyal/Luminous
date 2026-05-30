import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/features/today/domain/repositories/today_repository.dart';

class MockTodayRepository implements TodayRepository {
  const MockTodayRepository();

  @override
  Future<TodayDashboard> fetchDashboard() async {
    return const TodayDashboard(
      user: TodayUserSnapshot(
        moment: TodayDayMoment.morning,
        hasUnreadNotifications: true,
      ),
      water: TodayWaterSummary(completedCount: 5, targetCount: 8),
      medication: TodayMedicationSummary(
        medicineCount: 2,
        pendingCount: 1,
        nextDoseTimeLabel: '12:00',
        nextMedicine: TodayMedicationKind.atorvastatin,
      ),
      vitals: <TodayVitalSummary>[
        TodayVitalSummary(type: TodayVitalType.heartRate, valueLabel: '72'),
        TodayVitalSummary(
          type: TodayVitalType.bloodPressure,
          valueLabel: '118/76',
        ),
        TodayVitalSummary(type: TodayVitalType.sleep, valueLabel: '7.2'),
      ],
      mealSuggestion: TodayMealSuggestion(
        type: TodayMealSuggestionType.highProteinBalancedLunch,
      ),
      environment: TodayEnvironmentSummary(
        signals: <TodayEnvironmentSignal>[
          TodayEnvironmentSignal(
            type: TodayEnvironmentSignalType.pollen,
            level: TodayEnvironmentLevel.high,
          ),
          TodayEnvironmentSignal(
            type: TodayEnvironmentSignalType.uv,
            level: TodayEnvironmentLevel.medium,
          ),
        ],
      ),
      lumiSuggestion: TodayLumiSuggestion(
        type: TodayLumiSuggestionType.pollenProtection,
      ),
    );
  }
}

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return const MockTodayRepository();
});

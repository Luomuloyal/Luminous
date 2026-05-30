import 'package:luminous/features/today/domain/entities/today_dashboard.dart';

abstract interface class TodayRepository {
  Future<TodayDashboard> fetchDashboard();
}

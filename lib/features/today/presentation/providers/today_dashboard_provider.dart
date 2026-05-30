import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/features/today/data/repositories/mock_today_repository.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';

final todayDashboardProvider = FutureProvider<TodayDashboard>((ref) {
  return ref.watch(todayRepositoryProvider).fetchDashboard();
});

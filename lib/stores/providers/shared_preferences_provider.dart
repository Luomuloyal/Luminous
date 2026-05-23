import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 用于全局同步访问 SharedPreferences。在 main() 中初始化并通过 ProviderScope overrides 注入。
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main() via ProviderScope');
});

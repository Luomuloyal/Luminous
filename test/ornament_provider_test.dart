import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/theme/ornaments/ornament_provider.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'ornament provider normalizes legacy stored value and persists int',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        GlobalConstants.ORNAMENT_TRANSPARENCY_KEY: 't75',
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ornamentProvider.notifier);
      expect(container.read(ornamentProvider).transparencyPercent, 75);

      await notifier.init();

      expect(prefs.getInt(GlobalConstants.ORNAMENT_TRANSPARENCY_KEY), 75);
    },
  );

  test(
    'ornament warmup creates a session seed when ornaments are enabled',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ornamentProvider.notifier);
      await notifier.warmup();

      expect(container.read(ornamentProvider).isReady, isTrue);
    },
  );
}

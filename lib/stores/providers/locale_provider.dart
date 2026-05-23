import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/stores/locale_controller.dart'; // 复用原来的 enum
import 'package:luminous/stores/providers/shared_preferences_provider.dart';

class LocaleState {
  final AppLocalePreference preference;

  const LocaleState(this.preference);
}

class LocaleNotifier extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(GlobalConstants.LOCALE_KEY);
    return LocaleState(AppLocalePreference.fromStorage(stored));
  }

  Locale? get locale {
    switch (state.preference) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.zh:
        return const Locale('zh');
      case AppLocalePreference.en:
        return const Locale('en');
    }
  }

  Future<void> setLocalePreference(AppLocalePreference preference) async {
    if (state.preference == preference) return;
    state = LocaleState(preference);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(GlobalConstants.LOCALE_KEY, preference.name);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(() {
  return LocaleNotifier();
});

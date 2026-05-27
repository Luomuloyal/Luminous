import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';

enum AppLocalePreference {
  system,
  zh,
  en;

  static AppLocalePreference fromStorage(String? value) {
    return AppLocalePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppLocalePreference.system,
    );
  }
}

class LocaleState {
  final AppLocalePreference preference;

  const LocaleState(this.preference);

  Locale? get locale {
    switch (preference) {
      case AppLocalePreference.system:
        return null;
      case AppLocalePreference.zh:
        return const Locale('zh');
      case AppLocalePreference.en:
        return const Locale('en');
    }
  }
}

class LocaleNotifier extends Notifier<LocaleState> {
  @override
  LocaleState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final stored = prefs.getString(GlobalConstants.LOCALE_KEY);
    return LocaleState(AppLocalePreference.fromStorage(stored));
  }

  Locale? get locale {
    return state.locale;
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

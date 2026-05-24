import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/providers/shared_preferences_provider.dart';

enum AppThemeModePreference {
  system,
  light,
  dark;

  static AppThemeModePreference fromStorage(String? value) {
    return AppThemeModePreference.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeModePreference.system,
    );
  }
}

enum AppThemeStyle {
  softGlow,
  moonMist,
  divineTree,
  illusion,
  lightSand;

  static AppThemeStyle fromStorage(String? value) {
    return AppThemeStyle.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeStyle.softGlow,
    );
  }
}

class ThemeState {
  final AppThemeModePreference modePreference;
  final AppThemeStyle style;

  const ThemeState({required this.modePreference, required this.style});

  ThemeState copyWith({
    AppThemeModePreference? modePreference,
    AppThemeStyle? style,
  }) {
    return ThemeState(
      modePreference: modePreference ?? this.modePreference,
      style: style ?? this.style,
    );
  }
}

class ThemeNotifier extends Notifier<ThemeState> {
  @override
  ThemeState build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final storedThemeMode = prefs.getString(GlobalConstants.THEME_MODE_KEY);
    final storedThemeStyle = prefs.getString(GlobalConstants.THEME_STYLE_KEY);

    return ThemeState(
      modePreference: AppThemeModePreference.fromStorage(storedThemeMode),
      style: AppThemeStyle.fromStorage(storedThemeStyle),
    );
  }

  ThemeMode get themeMode {
    switch (state.modePreference) {
      case AppThemeModePreference.system:
        return ThemeMode.system;
      case AppThemeModePreference.light:
        return ThemeMode.light;
      case AppThemeModePreference.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> setThemePreference(AppThemeModePreference preference) async {
    if (state.modePreference == preference) return;
    state = state.copyWith(modePreference: preference);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(GlobalConstants.THEME_MODE_KEY, preference.name);
  }

  Future<void> setThemeStyle(AppThemeStyle style) async {
    if (state.style == style) return;
    state = state.copyWith(style: style);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(GlobalConstants.THEME_STYLE_KEY, style.name);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(() {
  return ThemeNotifier();
});

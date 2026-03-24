import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  moonMist;

  static AppThemeStyle fromStorage(String? value) {
    return AppThemeStyle.values.firstWhere(
      (item) => item.name == value,
      orElse: () => AppThemeStyle.softGlow,
    );
  }
}

/// 全局主题控制器。
///
/// 负责持久化并恢复：
/// - 主题模式（浅色 / 深色 / 跟随系统）；
/// - 主题风格（当前提供两套预设）。
class ThemeController extends GetxController {
  final Rx<AppThemeModePreference> themePreference =
      AppThemeModePreference.system.obs;
  final Rx<AppThemeStyle> themeStyle = AppThemeStyle.softGlow.obs;
  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs async {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  /// 当前应用真正使用的 ThemeMode。
  ThemeMode get themeMode {
    switch (themePreference.value) {
      case AppThemeModePreference.system:
        return ThemeMode.system;
      case AppThemeModePreference.light:
        return ThemeMode.light;
      case AppThemeModePreference.dark:
        return ThemeMode.dark;
    }
  }

  /// 兼容旧逻辑的只读暗色状态。
  bool get isDarkMode => themePreference.value == AppThemeModePreference.dark;

  bool get followsSystem =>
      themePreference.value == AppThemeModePreference.system;

  /// 启动时恢复上一次保存的主题选择。
  Future<void> init() async {
    final prefs = await _prefs;
    final storedThemeMode = prefs.getString(GlobalConstants.THEME_MODE_KEY);
    final storedThemeStyle = prefs.getString(GlobalConstants.THEME_STYLE_KEY);

    if (storedThemeMode != null) {
      themePreference.value = AppThemeModePreference.fromStorage(
        storedThemeMode,
      );
    } else {
      final legacyDarkMode = prefs.getBool(GlobalConstants.DARK_MODE_KEY);
      if (legacyDarkMode == null) {
        themePreference.value = AppThemeModePreference.system;
      } else {
        themePreference.value = legacyDarkMode
            ? AppThemeModePreference.dark
            : AppThemeModePreference.light;
      }
    }

    themeStyle.value = AppThemeStyle.fromStorage(storedThemeStyle);
  }

  /// 更新主题模式，并写入本地持久化。
  Future<void> setThemePreference(AppThemeModePreference preference) async {
    if (themePreference.value == preference) {
      return;
    }
    themePreference.value = preference;
    final prefs = await _prefs;
    await prefs.setString(GlobalConstants.THEME_MODE_KEY, preference.name);
  }

  /// 更新主题风格，并写入本地持久化。
  Future<void> setThemeStyle(AppThemeStyle style) async {
    if (themeStyle.value == style) {
      return;
    }
    themeStyle.value = style;
    final prefs = await _prefs;
    await prefs.setString(GlobalConstants.THEME_STYLE_KEY, style.name);
  }

  /// 兼容旧入口：显式切换明暗模式。
  Future<void> setDarkMode(bool enabled) async {
    await setThemePreference(
      enabled ? AppThemeModePreference.dark : AppThemeModePreference.light,
    );
  }
}

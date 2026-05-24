import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/constants/constants.dart';
import 'package:luminous/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Compatibility stub — AppThemeModePreference and AppThemeStyle enums have been moved
// to theme_provider.dart. This file is retained only for deprecated GetX controller
// compatibility and will be removed.

/// 全局主题控制器。
///
/// 负责持久化并恢复：
/// - 主题模式（浅色 / 深色 / 跟随系统）；
/// - 主题风格（当前提供多套预设）。
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

  bool get followsSystem =>
      themePreference.value == AppThemeModePreference.system;

  /// 启动时恢复上一次保存的主题选择。
  Future<void> init() async {
    final prefs = await _prefs;
    final storedThemeMode = prefs.getString(GlobalConstants.THEME_MODE_KEY);
    final storedThemeStyle = prefs.getString(GlobalConstants.THEME_STYLE_KEY);

    themePreference.value = AppThemeModePreference.fromStorage(storedThemeMode);

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
}

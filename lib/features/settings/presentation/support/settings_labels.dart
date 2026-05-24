part of '../settings.dart';

String _languagePreferenceLabel(
  AppLocalePreference preference, {
  AppLocalizations? l10n,
}) {
  switch (preference) {
    case AppLocalePreference.system:
      return l10n?.languageFollowSystem ?? '跟随系统';
    case AppLocalePreference.zh:
      return l10n?.languageChinese ?? '简体中文';
    case AppLocalePreference.en:
      return l10n?.languageEnglish ?? 'English';
  }
}

String _themeModeLabel(
  AppThemeModePreference preference, {
  AppLocalizations? l10n,
}) {
  switch (preference) {
    case AppThemeModePreference.system:
      return l10n?.settingsThemeModeOptionSystem ?? '跟随系统';
    case AppThemeModePreference.light:
      return l10n?.settingsThemeModeOptionLight ?? '浅色';
    case AppThemeModePreference.dark:
      return l10n?.settingsThemeModeOptionDark ?? '深色';
  }
}

IconData _themeModeIcon(AppThemeModePreference preference) {
  switch (preference) {
    case AppThemeModePreference.system:
      return Icons.brightness_auto_rounded;
    case AppThemeModePreference.light:
      return Icons.light_mode_rounded;
    case AppThemeModePreference.dark:
      return Icons.dark_mode_rounded;
  }
}

String _ornamentTransparencyLabel(
  AppOrnamentTransparencyPreference preference, {
  AppLocalizations? l10n,
}) {
  switch (preference) {
    case AppOrnamentTransparencyPreference.t0:
      return l10n?.settingsOrnamentOptionTransparency0 ?? '透明度 0%';
    case AppOrnamentTransparencyPreference.t25:
      return l10n?.settingsOrnamentOptionTransparency25 ?? '透明度 25%';
    case AppOrnamentTransparencyPreference.t50:
      return l10n?.settingsOrnamentOptionTransparency50 ?? '透明度 50%';
    case AppOrnamentTransparencyPreference.t75:
      return l10n?.settingsOrnamentOptionTransparency75 ?? '透明度 75%';
    case AppOrnamentTransparencyPreference.t100:
      return l10n?.settingsOrnamentOptionTransparency100 ?? '透明度 100%（关闭）';
  }
}

String _themeStyleLabel(AppThemeStyle style, {AppLocalizations? l10n}) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return l10n?.settingsThemeStyleOptionSoftGlow ?? '柔岚';
    case AppThemeStyle.moonMist:
      return l10n?.settingsThemeStyleOptionMoonMist ?? '月雾';
    case AppThemeStyle.divineTree:
      return l10n?.settingsThemeStyleOptionDivineTree ?? '神树';
    case AppThemeStyle.illusion:
      return l10n?.settingsThemeStyleOptionIllusion ?? '虚霭';
    case AppThemeStyle.lightSand:
      return l10n?.settingsThemeStyleOptionLightSand ?? '浅砂';
  }
}

String _themeStyleSubtitle(AppThemeStyle style, {AppLocalizations? l10n}) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return l10n?.settingsThemeStyleOptionSoftGlowDesc ??
          '淡蓝、浅紫和暖金同场，明快但不刺眼，整体更轻盈';
    case AppThemeStyle.moonMist:
      return l10n?.settingsThemeStyleOptionMoonMistDesc ??
          '主蓝色调里融入一丝紫雾，像月光下的冷蓝薄纱';
    case AppThemeStyle.divineTree:
      return l10n?.settingsThemeStyleOptionDivineTreeDesc ??
          '黄绿与柔金交错，像林荫透光，生机感更突出';
    case AppThemeStyle.illusion:
      return l10n?.settingsThemeStyleOptionIllusionDesc ??
          '偏紫色主调，带一点点蓝光，像夜雾里的霓虹边缘';
    case AppThemeStyle.lightSand:
      return l10n?.settingsThemeStyleOptionLightSandDesc ??
          '奶茶、枯粉与陶土色杂糅，温暖克制，像干燥砂岩与旧织物';
  }
}

List<Color> _themeStylePreview(AppThemeStyle style, bool isDark) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return isDark
          ? const [Color(0xFF0B1524), Color(0xFF1E3351), Color(0xFFD8C1FF)]
          : const [Color(0xFFF7FBFF), Color(0xFFF7EFCF), Color(0xFFEEE4FF)];
    case AppThemeStyle.moonMist:
      return isDark
          ? const [Color(0xFF081523), Color(0xFF1A314A), Color(0xFFC3C8FF)]
          : const [Color(0xFFF3F7FD), Color(0xFFE5EEFF), Color(0xFFE9EBFF)];
    case AppThemeStyle.divineTree:
      return isDark
          ? const [Color(0xFF0B120C), Color(0xFF203327), Color(0xFFE1CB85)]
          : const [Color(0xFFFBFAF0), Color(0xFFF0F5D9), Color(0xFFEBDDAB)];
    case AppThemeStyle.illusion:
      return isDark
          ? const [
              Color(0xFF110B1E),
              Color(0xFF2B1F45),
              Color(0xFF87A0E4),
              Color(0xFFD0C0FF),
            ]
          : const [
              Color(0xFFF7F4FF),
              Color(0xFFEDE4FF),
              Color(0xFFD4C3FF),
              Color(0xFF90A6EA),
            ];
    case AppThemeStyle.lightSand:
      return isDark
          ? const [Color(0xFF17110D), Color(0xFF32251E), Color(0xFFD8B1A7)]
          : const [Color(0xFFFAF1E9), Color(0xFFEEDBD0), Color(0xFFDDB6AA)];
  }
}

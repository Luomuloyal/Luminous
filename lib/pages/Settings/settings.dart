import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/soft_banner.dart';
import 'package:luminous/components/tinted_status_chip.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:luminous/pages/Settings/profile_settings.dart';
import 'package:luminous/stores/locale_controller.dart';
import 'package:luminous/stores/ornament_controller.dart';
import 'package:luminous/stores/theme_controller.dart';
import 'package:luminous/stores/user_controller.dart';

/// 设置总览页。
///
/// 采用常见 App 的“设置列表 -> 子设置页”结构。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AppCanvasPageScaffold(
      accentColor: scheme.secondary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 30,
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? '设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          _SettingsSectionCard(
            title: l10n?.settingsGeneralTitle ?? '通用设置',
            subtitle:
                l10n?.settingsGeneralSubtitle ?? '可按模块进入对应设置项，后续会继续扩展更多系统偏好',
            icon: Icons.tune_rounded,
            accentColor: scheme.secondary,
            secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
            ornamentKey: 'settings.hub',
            children: [
              _SettingsActionTile(
                icon: Icons.person_outline_rounded,
                accentColor: const Color(0xFF0EA5E9),
                title: '个人设置',
                subtitle: '完善头像、昵称、性别、生日和职业等个人资料',
                enabled: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileSettingsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _SettingsActionTile(
                icon: Icons.palette_outlined,
                accentColor: scheme.primary,
                title: l10n?.settingsThemeTitle ?? '主题设置',
                subtitle:
                    l10n?.settingsThemeSubtitle ?? '调整主题模式与主题风格，影响全局页面与组件视觉',
                enabled: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ThemeSettingsPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _SettingsActionTile(
                icon: Icons.language_rounded,
                accentColor: scheme.tertiary,
                title: l10n?.settingsLanguageTitle ?? '语言设置',
                subtitle:
                    l10n?.settingsLanguageSubtitle ?? '可自动跟随系统语言，也可手动固定应用语言',
                enabled: true,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LanguageSettingsPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 主题设置页。
///
/// 复用原有主题设置内容。
class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final ornamentController = Get.find<OrnamentController>();
    final userController = Get.find<UserController>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AppCanvasPageScaffold(
      accentColor: scheme.secondary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 30,
      appBar: AppBar(
        title: Text(l10n?.settingsThemeTitle ?? '主题设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          _SettingsHeroCard(
            themeController: themeController,
            userController: userController,
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            title: l10n?.settingsDisplayTitle ?? '显示',
            subtitle:
                l10n?.settingsDisplaySubtitle ?? '主题模式和主题风格会同时作用到首页、药品、相册与弹层',
            icon: Icons.palette_outlined,
            accentColor: scheme.secondary,
            secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
            ornamentKey: 'settings.display',
            children: [
              _DisplayPreferencesSection(
                themeController: themeController,
                ornamentController: ornamentController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 语言设置页。
///
/// 支持跟随系统、简体中文与英文三种语言偏好。
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeController = Get.find<LocaleController>();

    return AppCanvasPageScaffold(
      accentColor: scheme.tertiary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 30,
      appBar: AppBar(
        title: Text(l10n?.languagePageTitle ?? '语言设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          _LanguageHeroCard(localeController: localeController),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            title: l10n?.languageSectionTitle ?? '应用语言',
            subtitle:
                l10n?.languageSectionSubtitle ?? '选择“跟随系统”可自动匹配设备语言，也可手动固定语言',
            icon: Icons.translate_rounded,
            accentColor: scheme.tertiary,
            secondaryColor: Color.lerp(scheme.secondary, scheme.primary, 0.4)!,
            ornamentKey: 'settings.language',
            children: [
              _LanguagePreferenceSection(localeController: localeController),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguagePreferenceSection extends StatelessWidget {
  const _LanguagePreferenceSection({required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    Widget buildOption({
      required AppLocalePreference value,
      required String title,
      required String subtitle,
      required AppLocalePreference selected,
    }) {
      final isSelected = selected == value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => localeController.setLocalePreference(value),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            decoration: BoxDecoration(
              color: isSelected
                  ? appTintedSurface(
                      context,
                      scheme.primary,
                      lightAlpha: 0.12,
                      darkAlpha: 0.20,
                    )
                  : theme.cardColor.withValues(alpha: 0.34),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? appTintedBorder(
                        context,
                        scheme.primary,
                        lightAlpha: 0.24,
                        darkAlpha: 0.34,
                      )
                    : scheme.outline,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appTintedSurface(
                      context,
                      scheme.primary,
                      lightAlpha: 0.11,
                      darkAlpha: 0.20,
                    ),
                    border: Border.all(
                      color: appTintedBorder(
                        context,
                        scheme.primary,
                        lightAlpha: 0.20,
                        darkAlpha: 0.30,
                      ),
                    ),
                  ),
                  child: Icon(
                    isSelected ? Icons.check_rounded : Icons.language_rounded,
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 12.3,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Obx(() {
      final selected = localeController.localePreference.value;
      final selectedLabel = _languagePreferenceLabel(selected, l10n: l10n);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                scheme.tertiary,
                lightAlpha: 0.08,
                darkAlpha: 0.16,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: appTintedBorder(
                  context,
                  scheme.tertiary,
                  lightAlpha: 0.18,
                  darkAlpha: 0.28,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.translate_rounded, color: scheme.tertiary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.languageCurrentLabel(selectedLabel) ??
                        '当前语言：$selectedLabel',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          buildOption(
            value: AppLocalePreference.system,
            title: l10n?.languageFollowSystem ?? '跟随系统',
            subtitle: l10n?.languageFollowSystemSubtitle ?? '自动使用设备当前语言',
            selected: selected,
          ),
          const SizedBox(height: 8),
          buildOption(
            value: AppLocalePreference.zh,
            title: l10n?.languageChinese ?? '简体中文',
            subtitle: l10n?.languageChineseSubtitle ?? '应用文案使用中文',
            selected: selected,
          ),
          const SizedBox(height: 8),
          buildOption(
            value: AppLocalePreference.en,
            title: l10n?.languageEnglish ?? 'English',
            subtitle: l10n?.languageEnglishSubtitle ?? '应用文案使用英文',
            selected: selected,
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.languageNote ??
                '开启“跟随系统”后，当你把系统语言从中文切到英文，应用在下次打开时会自动切换；系统在运行中变更语言时也会同步更新。',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
      );
    });
  }
}

class _LanguageHeroCard extends StatelessWidget {
  const _LanguageHeroCard({required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final l10n = AppLocalizations.of(context);
      final selected = localeController.localePreference.value;
      final selectedLabel = _languagePreferenceLabel(selected, l10n: l10n);
      final selectedHint = switch (selected) {
        AppLocalePreference.system =>
          l10n?.languageHeroHintSystem ?? '应用将自动跟随设备语言切换',
        AppLocalePreference.zh =>
          l10n?.languageHeroHintChinese ?? '界面文案固定为简体中文',
        AppLocalePreference.en => l10n?.languageHeroHintEnglish ?? '界面文案固定为英文',
      };

      return SoftBannerCard(
        palette: SoftBannerPalettes.homeOf(context),
        ornamentKey: 'settings.language.hero',
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        builder: (context, theme) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.surfaceColor,
                      border: Border.all(color: theme.borderColor),
                    ),
                    child: Icon(
                      Icons.translate_rounded,
                      color: theme.accentColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.languagePageTitle ?? '语言设置',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedHint,
                          style: TextStyle(
                            color: theme.secondaryTextColor,
                            fontSize: 12.8,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TintedStatusChip(
                icon: Icons.language_rounded,
                text:
                    l10n?.languageSelectedLabel(selectedLabel) ??
                    '已选：$selectedLabel',
                color: theme.surfaceTextColor,
                backgroundColor: theme.surfaceColor,
                showBorder: false,
                iconSize: 16,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
              ),
            ],
          );
        },
      );
    });
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
    required this.accentColor,
    required this.secondaryColor,
    required this.ornamentKey,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;
  final Color accentColor;
  final Color secondaryColor;
  final String ornamentKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: ornamentKey,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      radius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appTintedSurface(
                    context,
                    accentColor,
                    lightAlpha: 0.12,
                    darkAlpha: 0.20,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.22,
                      darkAlpha: 0.30,
                    ),
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 16.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.6,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0),
                  accentColor.withValues(alpha: 0.20),
                  accentColor.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard({
    required this.themeController,
    required this.userController,
  });

  final ThemeController themeController;
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final l10n = AppLocalizations.of(context);
      final preference = themeController.themePreference.value;
      final style = themeController.themeStyle.value;
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;
      final loggedIn = userController.isLoggedIn;
      final userLabel = loggedIn
          ? (userController.user.value?.displayTitle ??
                (l10n?.settingsHeroAccountLoggedIn ?? '账号已登录'))
          : (l10n?.settingsHeroAccountLoggedOut ?? '未登录');

      return SoftBannerCard(
        palette: SoftBannerPalettes.mineOf(context),
        ornamentKey: 'settings.hero',
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        builder: (context, theme) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.surfaceColor,
                      border: Border.all(color: theme.borderColor),
                    ),
                    child: Icon(Icons.tune_rounded, color: theme.accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.settingsHeroTitle ?? '界面与偏好',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resolvedDark
                              ? (l10n?.settingsHeroMoodDark ??
                                    '现在是更安静的夜间观感，页面会一起跟随当前主题节奏')
                              : (l10n?.settingsHeroMoodLight ??
                                    '现在是更通透的浅色观感，页面会一起保持柔和层次'),
                          style: TextStyle(
                            color: theme.secondaryTextColor,
                            fontSize: 13,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TintedStatusChip(
                    icon: _themeModeIcon(preference),
                    text: _themeModeLabel(preference, l10n: l10n),
                    color: theme.surfaceTextColor,
                    backgroundColor: theme.surfaceColor,
                    showBorder: false,
                    iconSize: 16,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TintedStatusChip(
                    icon: Icons.auto_awesome_rounded,
                    text: _themeStyleLabel(style, l10n: l10n),
                    color: theme.surfaceTextColor,
                    backgroundColor: theme.surfaceColor,
                    showBorder: false,
                    iconSize: 16,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  ),
                  TintedStatusChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    text: loggedIn
                        ? (l10n?.settingsHeroAccountLoggedIn ?? '账号已登录')
                        : (l10n?.settingsHeroLocalMode ?? '本地模式'),
                    color: theme.surfaceTextColor,
                    backgroundColor: theme.surfaceColor,
                    showBorder: false,
                    iconSize: 16,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: theme.surfaceColor.withValues(
                    alpha: resolvedDark ? 0.90 : 0.76,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: theme.borderColor),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      color: theme.accentColor,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userLabel,
                            style: TextStyle(
                              color: theme.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            loggedIn
                                ? (l10n?.settingsHeroLoggedInHint ??
                                      '你可以继续调整主题风格，账号状态会保留在这台设备上')
                                : (l10n?.settingsHeroLoggedOutHint ??
                                      '现在也能正常使用应用，登录只会额外开启轻量同步能力'),
                            style: TextStyle(
                              color: theme.secondaryTextColor,
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _DisplayPreferencesSection extends StatelessWidget {
  const _DisplayPreferencesSection({
    required this.themeController,
    required this.ornamentController,
  });

  final ThemeController themeController;
  final OrnamentController ornamentController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() {
      final l10n = AppLocalizations.of(context);
      final preference = themeController.themePreference.value;
      final selectedStyle = themeController.themeStyle.value;
      final ornamentPercent = ornamentController.transparencyPercent.value;
      final matchedPreset = ornamentController.matchedPreset;
      const ornamentOptions = <AppOrnamentTransparencyPreference>[
        AppOrnamentTransparencyPreference.t0,
        AppOrnamentTransparencyPreference.t25,
        AppOrnamentTransparencyPreference.t50,
        AppOrnamentTransparencyPreference.t75,
        AppOrnamentTransparencyPreference.t100,
      ];
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsFieldTitle(
            icon: preference == AppThemeModePreference.system
                ? Icons.brightness_auto_rounded
                : (resolvedDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded),
            title: l10n?.settingsThemeModeFieldTitle ?? '主题模式',
            description:
                l10n?.settingsThemeModeFieldSubtitle ?? '支持跟随系统、固定浅色和固定深色三种方式',
            color: scheme.primary,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeModePreference.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(_themeModeLabel(item, l10n: l10n)),
                    avatar: Icon(
                      _themeModeIcon(item),
                      size: 18,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                    ),
                    selected: preference == item,
                    onSelected: (_) {
                      themeController.setThemePreference(item);
                    },
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: preference == item
                          ? scheme.primary
                          : scheme.onSurface,
                    ),
                    side: BorderSide(
                      color: preference == item
                          ? scheme.primary.withValues(alpha: 0.28)
                          : scheme.outline,
                    ),
                    backgroundColor: theme.cardColor.withValues(alpha: 0.45),
                    selectedColor: scheme.primary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            preference == AppThemeModePreference.system
                ? (l10n?.settingsThemeModeCurrentSystem(
                        resolvedDark
                            ? (l10n.settingsThemeModeOptionDark)
                            : (l10n.settingsThemeModeOptionLight),
                      ) ??
                      '当前跟随系统，系统正在使用${resolvedDark ? '深色' : '浅色'}外观')
                : (l10n?.settingsThemeModeCurrentFixed(
                        resolvedDark
                            ? (l10n.settingsThemeModeOptionDark)
                            : (l10n.settingsThemeModeOptionLight),
                      ) ??
                      '当前固定为${resolvedDark ? '深色' : '浅色'}外观'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsFieldTitle(
            icon: Icons.blur_on_rounded,
            title: l10n?.settingsOrnamentFieldTitle ?? '氛围装饰',
            description:
                l10n?.settingsOrnamentFieldSubtitle ??
                '支持透明度 0%、25%、50%、75% 与 100%（100% 表示关闭）',
            color: scheme.tertiary,
          ),
          const SizedBox(height: 8),
          _OrnamentPreviewCard(
            accentColor: scheme.tertiary,
            secondaryColor: Color.lerp(scheme.primary, scheme.secondary, 0.45)!,
            transparencyPercent: ornamentPercent,
          ),
          const SizedBox(height: 12),
          _SettingsFieldTitle(
            icon: Icons.grid_view_rounded,
            title: l10n?.settingsOrnamentPresetTitle ?? '快捷档位',
            description:
                l10n?.settingsOrnamentPresetSubtitle ??
                '快速切换常用透明度配置，适合一键调整视觉强弱',
            color: scheme.tertiary,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ornamentOptions
                .map(
                  (item) => ChoiceChip(
                    label: Text(_ornamentTransparencyLabel(item, l10n: l10n)),
                    avatar: Icon(
                      item == AppOrnamentTransparencyPreference.t100
                          ? Icons.visibility_off_rounded
                          : Icons.blur_on_rounded,
                      size: 18,
                      color: matchedPreset == item
                          ? scheme.tertiary
                          : scheme.onSurfaceVariant,
                    ),
                    selected: matchedPreset == item,
                    onSelected: (_) {
                      ornamentController.setTransparencyPreference(item);
                    },
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: matchedPreset == item
                          ? scheme.tertiary
                          : scheme.onSurface,
                    ),
                    side: BorderSide(
                      color: matchedPreset == item
                          ? scheme.tertiary.withValues(alpha: 0.28)
                          : scheme.outline,
                    ),
                    backgroundColor: theme.cardColor.withValues(alpha: 0.45),
                    selectedColor: scheme.tertiary.withValues(alpha: 0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _SettingsFieldTitle(
            icon: Icons.tune_rounded,
            title: l10n?.settingsOrnamentSliderTitle ?? '自定义透明度',
            description:
                l10n?.settingsOrnamentSliderSubtitle ??
                '支持 0%-100%（步进 5%），可按设备观感精细调节',
            color: scheme.tertiary,
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: scheme.tertiary,
              inactiveTrackColor: scheme.tertiary.withValues(alpha: 0.22),
              thumbColor: scheme.tertiary,
              overlayColor: scheme.tertiary.withValues(alpha: 0.16),
              valueIndicatorColor: scheme.tertiary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Slider(
              min: 0,
              max: 100,
              divisions: 20,
              value: ornamentPercent.toDouble(),
              label: '$ornamentPercent%',
              onChanged: (value) {
                ornamentController.setTransparencyPercent(value.round());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n?.settingsOrnamentSliderMinLabel ?? '0%（最明显）',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  l10n?.settingsOrnamentSliderMaxLabel ?? '100%（关闭）',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.settingsOrnamentCurrentPercent(ornamentPercent) ??
                (l10n?.settingsOrnamentCurrent(
                      '${ornamentPercent.toString()}%',
                    ) ??
                    '当前氛围装饰透明度：${ornamentPercent.toString()}%'),
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsFieldTitle(
            icon: Icons.palette_outlined,
            title: l10n?.settingsThemeStyleFieldTitle ?? '主题风格',
            description:
                l10n?.settingsThemeStyleFieldSubtitle ??
                '柔岚、月雾、神树、虚霭、浅砂五套配色会一起影响环境光、横幅和分区块',
            color: scheme.secondary,
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final styles = AppThemeStyle.values;
              final columnCount = constraints.maxWidth >= 720
                  ? 3
                  : (constraints.maxWidth >= 430 ? 2 : 1);
              final spacing = 10.0;
              final itemWidth =
                  (constraints.maxWidth - (columnCount - 1) * spacing) /
                  columnCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: styles
                    .map(
                      (style) => SizedBox(
                        width: itemWidth,
                        child: _ThemeStyleCard(
                          style: style,
                          selected: selectedStyle == style,
                          l10n: l10n,
                          onTap: () => themeController.setThemeStyle(style),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    });
  }
}

class _ThemeStyleCard extends StatelessWidget {
  const _ThemeStyleCard({
    required this.style,
    required this.selected,
    this.l10n,
    required this.onTap,
  });

  final AppThemeStyle style;
  final bool selected;
  final AppLocalizations? l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preview = _themeStylePreview(
      style,
      theme.brightness == Brightness.dark,
    );
    final accent = preview[preview.length - 1];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.10)
              : theme.cardColor.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.primary.withValues(alpha: 0.34)
                : scheme.outline,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.10),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _themeStyleLabel(style, l10n: l10n),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: selected ? 1 : 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n?.settingsThemeStyleInUseBadge ?? '当前使用',
                      style: TextStyle(
                        color: scheme.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(colors: preview),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -12,
                    right: -10,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.30),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: preview
                          .map(
                            (color) => Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: 0.92),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _themeStyleSubtitle(style, l10n: l10n),
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnamentPreviewCard extends StatelessWidget {
  const _OrnamentPreviewCard({
    required this.accentColor,
    required this.secondaryColor,
    required this.transparencyPercent,
  });

  final Color accentColor;
  final Color secondaryColor;
  final int transparencyPercent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final visibilityPercent = 100 - transparencyPercent;

    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: 'settings.ornament.preview',
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appTintedSurface(
                context,
                accentColor,
                lightAlpha: 0.12,
                darkAlpha: 0.2,
              ),
              border: Border.all(
                color: appTintedBorder(
                  context,
                  accentColor,
                  lightAlpha: 0.18,
                  darkAlpha: 0.26,
                ),
              ),
            ),
            child: Icon(Icons.auto_awesome_rounded, color: accentColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.settingsOrnamentPreviewTitle ?? '实时预览',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n?.settingsOrnamentPreviewSubtitle ?? '上方渐变块会实时反映当前氛围装饰强度',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accentColor,
                lightAlpha: 0.1,
                darkAlpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${visibilityPercent.toString()}%',
              style: TextStyle(
                color: accentColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsFieldTitle extends StatelessWidget {
  const _SettingsFieldTitle({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: appTintedSurface(
              context,
              color,
              lightAlpha: 0.11,
              darkAlpha: 0.20,
            ),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: appTintedBorder(
                context,
                color,
                lightAlpha: 0.22,
                darkAlpha: 0.32,
              ),
            ),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final cardColor = enabled
        ? appTintedSurface(
            context,
            accentColor,
            lightAlpha: 0.10,
            darkAlpha: 0.18,
          )
        : theme.cardColor.withValues(alpha: 0.36);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: enabled
                  ? appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.24,
                      darkAlpha: 0.34,
                    )
                  : scheme.outline.withValues(alpha: 0.75),
            ),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appTintedSurface(
                    context,
                    accentColor,
                    lightAlpha: 0.16,
                    darkAlpha: 0.26,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.24,
                      darkAlpha: 0.34,
                    ),
                  ),
                ),
                child: Icon(
                  icon,
                  color: enabled
                      ? accentColor
                      : scheme.onSurfaceVariant.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.8,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: appTintedSurface(
                    context,
                    accentColor,
                    lightAlpha: 0.10,
                    darkAlpha: 0.18,
                  ),
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.20,
                      darkAlpha: 0.30,
                    ),
                  ),
                ),
                child: Icon(
                  enabled ? Icons.chevron_right_rounded : Icons.remove_rounded,
                  color: scheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
          ? const [Color(0xFF0A1424), Color(0xFF1D3050), Color(0xFF6B5EA3)]
          : const [Color(0xFFECF7FF), Color(0xFFF9EFD9), Color(0xFFEEE4FF)];
    case AppThemeStyle.moonMist:
      return isDark
          ? const [Color(0xFF061423), Color(0xFF17365A), Color(0xFF7480DB)]
          : const [Color(0xFFEFF6FF), Color(0xFFDEE9FF), Color(0xFFE8E5FF)];
    case AppThemeStyle.divineTree:
      return isDark
          ? const [Color(0xFF0A120C), Color(0xFF1F3124), Color(0xFF7C6A32)]
          : const [Color(0xFFFEF8DB), Color(0xFFF2F8D8), Color(0xFFDDECB2)];
    case AppThemeStyle.illusion:
      return isDark
          ? const [
              Color(0xFF120A20),
              Color(0xFF2C1D46),
              Color(0xFF4E54A2),
              Color(0xFFD7BCFF),
            ]
          : const [
              Color(0xFFF8F2FF),
              Color(0xFFEDE0FF),
              Color(0xFFC7B0FF),
              Color(0xFF8495EA),
            ];
    case AppThemeStyle.lightSand:
      return isDark
          ? const [Color(0xFF17110D), Color(0xFF31241D), Color(0xFF946F5A)]
          : const [Color(0xFFF7EFE7), Color(0xFFEAD9CF), Color(0xFFD6B7AA)];
  }
}

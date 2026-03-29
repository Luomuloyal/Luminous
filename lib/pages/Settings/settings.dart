import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:luminous/components/app_canvas.dart';
import 'package:luminous/components/app_surface.dart';
import 'package:luminous/components/soft_banner.dart';
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

    return AppCanvasPageScaffold(
      accentColor: scheme.secondary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 36,
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
        children: [
          _SettingsHubHeroCard(
            accentColor: scheme.primary,
            secondaryColor: scheme.secondary,
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            title: '通用设置',
            subtitle: '可按模块进入对应设置项，后续会继续扩展更多系统偏好',
            icon: Icons.tune_rounded,
            accentColor: scheme.secondary,
            secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
            ornamentKey: 'settings.hub',
            children: [
              _SettingsActionTile(
                icon: Icons.palette_outlined,
                accentColor: scheme.primary,
                title: '主题设置',
                subtitle: '调整主题模式与主题风格，影响全局页面与组件视觉',
                caption: '进入主题设置',
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
                title: '语言设置',
                subtitle: '当前支持中文，英文能力将于后续版本上线',
                caption: '进入语言设置',
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
    final userController = Get.find<UserController>();
    final scheme = Theme.of(context).colorScheme;

    return AppCanvasPageScaffold(
      accentColor: scheme.secondary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 36,
      appBar: AppBar(
        title: const Text('主题设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
        children: [
          _SettingsHeroCard(
            themeController: themeController,
            userController: userController,
          ),
          const SizedBox(height: 12),
          _SettingsSectionCard(
            title: '显示',
            subtitle: '主题模式和主题风格会同时作用到首页、药品、相册与弹层',
            icon: Icons.palette_outlined,
            accentColor: scheme.secondary,
            secondaryColor: Color.lerp(scheme.primary, scheme.tertiary, 0.5)!,
            ornamentKey: 'settings.display',
            children: [
              _DisplayPreferencesSection(themeController: themeController),
            ],
          ),
        ],
      ),
    );
  }
}

/// 语言设置页。
///
/// 当前先提供中文，英文先占位。
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCanvasPageScaffold(
      accentColor: scheme.tertiary,
      secondaryAccentColor: scheme.primary,
      safeAreaBottom: true,
      appBarSpacing: 36,
      appBar: AppBar(
        title: const Text('语言设置'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
        children: [
          _SettingsSectionCard(
            title: '应用语言',
            subtitle: '当前默认使用简体中文，英文入口先保留占位用于后续版本扩展',
            icon: Icons.translate_rounded,
            accentColor: scheme.tertiary,
            secondaryColor: Color.lerp(scheme.secondary, scheme.primary, 0.4)!,
            ornamentKey: 'settings.language',
            children: const [_LanguagePlaceholderSection()],
          ),
        ],
      ),
    );
  }
}

class _LanguagePlaceholderSection extends StatelessWidget {
  const _LanguagePlaceholderSection();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Icon(
                  Icons.check_circle_rounded,
                  color: scheme.primary,
                ),
                title: const Text('简体中文'),
                subtitle: const Text('当前已启用'),
              ),
              Divider(height: 1, color: scheme.outline),
              ListTile(
                leading: Icon(
                  Icons.radio_button_unchecked_rounded,
                  color: scheme.onSurfaceVariant,
                ),
                title: const Text('English'),
                subtitle: const Text('即将支持'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '说明：当前仅提供中文，英文入口已预留，后续版本会逐步补齐文案与本地化资源。',
          style: TextStyle(
            color: scheme.onSurfaceVariant,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _SettingsHubHeroCard extends StatelessWidget {
  const _SettingsHubHeroCard({
    required this.accentColor,
    required this.secondaryColor,
  });

  final Color accentColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: 'settings.hub.hero',
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: appTintedSurface(
                context,
                accentColor,
                lightAlpha: 0.10,
                darkAlpha: 0.18,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: appTintedBorder(
                  context,
                  accentColor,
                  lightAlpha: 0.18,
                  darkAlpha: 0.24,
                ),
              ),
            ),
            child: Icon(Icons.settings_outlined, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '偏好设置',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '从这里进入主题和语言设置，后续可继续扩展通知、隐私等模块。',
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 12.8,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: appTintedSurface(
                    context,
                    accentColor,
                    lightAlpha: 0.10,
                    darkAlpha: 0.18,
                  ),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.18,
                      darkAlpha: 0.24,
                    ),
                  ),
                ),
                child: Icon(icon, color: accentColor),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 12.5,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
      final preference = themeController.themePreference.value;
      final style = themeController.themeStyle.value;
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;
      final loggedIn = userController.isLoggedIn;
      final userLabel = loggedIn
          ? (userController.user.value?.displayTitle ?? '账号已登录')
          : '未登录';

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
                          '界面与偏好',
                          style: TextStyle(
                            color: theme.textColor,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resolvedDark
                              ? '现在是更安静的夜间观感，页面会一起跟随当前主题节奏'
                              : '现在是更通透的浅色观感，页面会一起保持柔和层次',
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
                  _SettingsInfoChip(
                    icon: _themeModeIcon(preference),
                    text: _themeModeLabel(preference),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SettingsInfoChip(
                    icon: Icons.auto_awesome_rounded,
                    text: _themeStyleLabel(style),
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
                  ),
                  _SettingsInfoChip(
                    icon: loggedIn
                        ? Icons.cloud_done_rounded
                        : Icons.cloud_off_rounded,
                    text: loggedIn ? '账号已登录' : '本地模式',
                    backgroundColor: theme.surfaceColor,
                    foregroundColor: theme.surfaceTextColor,
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
                                ? '你可以继续调整主题风格，账号状态会保留在这台设备上'
                                : '现在也能正常使用应用，登录只会额外开启轻量同步能力',
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

class _SettingsInfoChip extends StatelessWidget {
  const _SettingsInfoChip({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: foregroundColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisplayPreferencesSection extends StatelessWidget {
  const _DisplayPreferencesSection({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Obx(() {
      final preference = themeController.themePreference.value;
      final selectedStyle = themeController.themeStyle.value;
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
            title: '主题模式',
            description: '支持跟随系统、固定浅色和固定深色三种方式',
            color: scheme.primary,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppThemeModePreference.values
                .map(
                  (item) => ChoiceChip(
                    label: Text(_themeModeLabel(item)),
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
                ? '当前跟随系统，系统正在使用${resolvedDark ? '深色' : '浅色'}外观'
                : '当前固定为${resolvedDark ? '深色' : '浅色'}外观',
            style: TextStyle(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _SettingsFieldTitle(
            icon: Icons.palette_outlined,
            title: '主题风格',
            description: '柔岚、月雾、神树、虚霭、霜尘、浅砂、烟波七套配色会一起影响环境光、横幅和分区块',
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
    required this.onTap,
  });

  final AppThemeStyle style;
  final bool selected;
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
                    _themeStyleLabel(style),
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
                      '当前使用',
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
              _themeStyleSubtitle(style),
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
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
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
    required this.caption,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String caption;
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
            lightAlpha: 0.08,
            darkAlpha: 0.16,
          )
        : theme.cardColor.withValues(alpha: 0.36);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: enabled
                  ? appTintedBorder(
                      context,
                      accentColor,
                      lightAlpha: 0.18,
                      darkAlpha: 0.26,
                    )
                  : scheme.outline.withValues(alpha: 0.75),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: enabled ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(13),
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
                    const SizedBox(height: 8),
                    Text(
                      caption,
                      style: TextStyle(
                        color: enabled
                            ? accentColor
                            : scheme.onSurfaceVariant.withValues(alpha: 0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                enabled ? Icons.chevron_right_rounded : Icons.remove_rounded,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _themeModeLabel(AppThemeModePreference preference) {
  switch (preference) {
    case AppThemeModePreference.system:
      return '跟随系统';
    case AppThemeModePreference.light:
      return '浅色';
    case AppThemeModePreference.dark:
      return '深色';
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

String _themeStyleLabel(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return '柔岚';
    case AppThemeStyle.moonMist:
      return '月雾';
    case AppThemeStyle.divineTree:
      return '神树';
    case AppThemeStyle.illusion:
      return '虚霭';
    case AppThemeStyle.frostDust:
      return '霜尘';
    case AppThemeStyle.lightSand:
      return '浅砂';
    case AppThemeStyle.smokeWaves:
      return '烟波';
  }
}

String _themeStyleSubtitle(AppThemeStyle style) {
  switch (style) {
    case AppThemeStyle.softGlow:
      return '淡蓝、浅紫和暖金同场，明快但不刺眼，整体更轻盈';
    case AppThemeStyle.moonMist:
      return '主蓝色调里融入一丝紫雾，像月光下的冷蓝薄纱';
    case AppThemeStyle.divineTree:
      return '黄绿与柔金交错，像林荫透光，生机感更突出';
    case AppThemeStyle.illusion:
      return '偏紫色主调，带一点点蓝光，像夜雾里的霓虹边缘';
    case AppThemeStyle.frostDust:
      return '灰绿、苔色与米白浅亚麻交融，像覆着晨霜的草地与石苔';
    case AppThemeStyle.lightSand:
      return '奶茶、枯粉与陶土色杂糅，温暖克制，像干燥砂岩与旧织物';
    case AppThemeStyle.smokeWaves:
      return '青灰和雾蓝叠出水汽感，淡墨收尾，冷静又有远山层次';
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
    case AppThemeStyle.frostDust:
      return isDark
          ? const [Color(0xFF101611), Color(0xFF243129), Color(0xFF809A8B)]
          : const [Color(0xFFF4F3EE), Color(0xFFE7E2D8), Color(0xFFD1DED3)];
    case AppThemeStyle.lightSand:
      return isDark
          ? const [Color(0xFF17110D), Color(0xFF31241D), Color(0xFF946F5A)]
          : const [Color(0xFFF7EFE7), Color(0xFFEAD9CF), Color(0xFFD6B7AA)];
    case AppThemeStyle.smokeWaves:
      return isDark
          ? const [Color(0xFF0B1116), Color(0xFF1F2B35), Color(0xFF6F879C)]
          : const [Color(0xFFEDF2F5), Color(0xFFDDE6ED), Color(0xFFC1CED8)];
  }
}

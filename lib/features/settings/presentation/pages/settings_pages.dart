part of '../settings.dart';

/// 设置总览页。
///
/// 采用常见 App 的“设置列表 -> 子设置页”结构。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                title: l10n?.settingsProfileTitle ?? '个人设置',
                subtitle:
                    l10n?.settingsProfileSubtitle ?? '完善头像、昵称、性别、生日和职业等个人资料',
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
          const SizedBox(height: 32),
          TextButton.icon(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('退出登录'),
                  content: const Text(
                    '确认要退出当前账号吗？您的本地数据（如偏好设置）将会保留，但需要重新登录才能继续同步。',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: FilledButton.styleFrom(
                        backgroundColor: scheme.error,
                        foregroundColor: scheme.onError,
                      ),
                      child: const Text('确认退出'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authServiceProvider).logout();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
            icon: Icon(Icons.logout_rounded, color: scheme.error),
            label: Text(
              '退出登录',
              style: TextStyle(
                color: scheme.error,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: scheme.errorContainer.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题设置页。
///
/// 复用原有主题设置内容。
class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.read(themeProvider.notifier);
    final themeState = ref.watch(themeProvider);
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
            themeNotifier: themeNotifier,
            themeState: themeState,
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
                themeNotifier: themeNotifier,
                themeState: themeState,
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
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final localeNotifier = ref.read(localeProvider.notifier);
    final localeState = ref.watch(localeProvider);

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
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          _LanguageHeroCard(
            localeNotifier: localeNotifier,
            localeState: localeState,
          ),
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
              _LanguagePreferenceSection(
                localeNotifier: localeNotifier,
                localeState: localeState,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

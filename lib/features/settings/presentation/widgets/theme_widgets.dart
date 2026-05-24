part of '../settings.dart';

class _SettingsHeroCard extends ConsumerWidget {
  const _SettingsHeroCard({
    required this.themeNotifier,
    required this.themeState,
  });

  final ThemeNotifier themeNotifier;
  final ThemeState themeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return (() {
      final l10n = AppLocalizations.of(context);
      final preference = themeState.modePreference;
      final style = themeState.style;
      final systemBrightness = MediaQuery.platformBrightnessOf(context);
      final resolvedDark = preference == AppThemeModePreference.system
          ? systemBrightness == Brightness.dark
          : preference == AppThemeModePreference.dark;

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
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  TintedStatusChip(
                    icon: _themeModeIcon(preference),
                    text: _themeModeLabel(preference, l10n: l10n),
                    color: theme.surfaceTextColor,
                    backgroundColor: theme.surfaceColor,
                    showBorder: false,
                    enablePopup: false,
                    iconSize: 16,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  ),
                  TintedStatusChip(
                    icon: Icons.auto_awesome_rounded,
                    text: _themeStyleLabel(style, l10n: l10n),
                    color: theme.surfaceTextColor,
                    backgroundColor: theme.surfaceColor,
                    showBorder: false,
                    enablePopup: false,
                    iconSize: 16,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                  ),
                ],
              ),
            ],
          );
        },
      );
    })();
  }
}

class _DisplayPreferencesSection extends ConsumerWidget {
  const _DisplayPreferencesSection({
    required this.themeNotifier,
    required this.themeState,
  });

  final ThemeNotifier themeNotifier;
  final ThemeState themeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final ornamentNotifier = ref.read(ornamentProvider.notifier);
    final ornamentState = ref.watch(ornamentProvider);
    return (() {
      final l10n = AppLocalizations.of(context);
      final preference = themeState.modePreference;
      final selectedStyle = themeState.style;
      final ornamentPercent = ornamentState.transparencyPercent;
      final matchedPreset = ornamentState.matchedPreset;
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
                      themeNotifier.setThemePreference(item);
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
                      ornamentNotifier.setTransparencyPreference(item);
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
                ornamentNotifier.setTransparencyPercent(value.round());
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
                  : (constraints.maxWidth >= 500 ? 2 : 1);
              const spacing = 10.0;
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
                          onTap: () => themeNotifier.setThemeStyle(style),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      );
    })();
  }
}

class _ThemeStyleCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final preview = _themeStylePreview(
      style,
      theme.brightness == Brightness.dark,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
            Container(
              width: double.infinity,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(colors: preview),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: preview.take(3).map((color) {
                      return Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withValues(alpha: 0.92),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _themeStyleLabel(style, l10n: l10n),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                fontSize: 14.6,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _themeStyleSubtitle(style, l10n: l10n),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrnamentPreviewCard extends ConsumerWidget {
  const _OrnamentPreviewCard({
    required this.accentColor,
    required this.secondaryColor,
    required this.transparencyPercent,
  });

  final Color accentColor;
  final Color secondaryColor;
  final int transparencyPercent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final visibilityPercent = 100 - transparencyPercent;

    return AppSectionCard(
      accentColor: accentColor,
      secondaryColor: secondaryColor,
      ornamentKey: 'settings.ornament.preview',
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      radius: 16,
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
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
            child: Icon(
              Icons.auto_awesome_rounded,
              color: accentColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.settingsOrnamentPreviewTitle ?? '实时预览',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n?.settingsOrnamentPreviewSubtitle ?? '上方渐变块会实时反映当前氛围装饰强度',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

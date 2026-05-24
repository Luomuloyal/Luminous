part of '../settings.dart';

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

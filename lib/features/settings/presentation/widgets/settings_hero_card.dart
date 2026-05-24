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

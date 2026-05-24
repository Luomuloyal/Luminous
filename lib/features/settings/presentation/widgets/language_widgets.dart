part of '../settings.dart';

class _LanguagePreferenceSection extends ConsumerWidget {
  const _LanguagePreferenceSection({
    required this.localeNotifier,
    required this.localeState,
  });

  final LocaleNotifier localeNotifier;
  final LocaleState localeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onTap: () => localeNotifier.setLocalePreference(value),
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

    return (() {
      final selected = localeState.preference;
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
    })();
  }
}

class _LanguageHeroCard extends ConsumerWidget {
  const _LanguageHeroCard({
    required this.localeNotifier,
    required this.localeState,
  });

  final LocaleNotifier localeNotifier;
  final LocaleState localeState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return (() {
      final l10n = AppLocalizations.of(context);
      final selected = localeState.preference;
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
    })();
  }
}

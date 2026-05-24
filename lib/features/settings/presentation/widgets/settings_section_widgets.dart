part of '../settings.dart';

class _SettingsSectionCard extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

class _SettingsFieldTitle extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

class _SettingsActionTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
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

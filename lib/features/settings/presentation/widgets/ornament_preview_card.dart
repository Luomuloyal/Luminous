part of '../settings.dart';

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

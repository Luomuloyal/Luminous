part of '../app_surface.dart';

Color appTintedSurface(
  BuildContext context,
  Color accent, {
  double lightAlpha = 0.08,
  double darkAlpha = 0.14,
  Color? baseColor,
}) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(
      alpha: theme.brightness == Brightness.dark ? darkAlpha : lightAlpha,
    ),
    baseColor ?? (theme.cardTheme.color ?? theme.colorScheme.surface),
  );
}

Color appTintedBorder(
  BuildContext context,
  Color accent, {
  double lightAlpha = 0.14,
  double darkAlpha = 0.22,
  Color? baseColor,
}) {
  final theme = Theme.of(context);
  return Color.alphaBlend(
    accent.withValues(
      alpha: theme.brightness == Brightness.dark ? darkAlpha : lightAlpha,
    ),
    baseColor ?? theme.colorScheme.outline,
  );
}

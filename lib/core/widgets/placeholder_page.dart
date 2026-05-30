import 'package:flutter/material.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final layout = AppLayoutTokens.resolve(width);

    return DecoratedBox(
      decoration: BoxDecoration(color: surface.canvasSoft),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: layout.maxContentWidth * 0.42),
          padding: EdgeInsets.all(layout.cardPaddingLarge),
          decoration: BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(AppRadiusTokens.lg),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_rounded,
                size: width < 600 ? 42 : 48,
                color: surface.mute.withValues(alpha: 0.6),
              ),
              SizedBox(height: layout.componentGap),
              Text(
                '$label · 即将上线',
                style: typography.displaySm.copyWith(color: scheme.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                '这一栏的结构已经预留完成，下一步会按新的多端设计系统重建。',
                style: typography.bodySm.copyWith(color: surface.body),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

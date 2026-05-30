import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:luminous/l10n/app_localizations.dart';

/// 今日页。
class TodayPage extends ConsumerStatefulWidget {
  const TodayPage({super.key});

  @override
  ConsumerState<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends ConsumerState<TodayPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authSessionProvider.notifier).restore());
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final typography = width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);
    final layout = AppLayoutTokens.resolve(width);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColorTokens.canvas,
            AppColorTokens.canvasSoft,
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: layout.pageHorizontalPadding,
                vertical: width < 600
                    ? AppSpacingTokens.x4l
                    : AppSpacingTokens.x5l,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight -
                      ((width < 600
                              ? AppSpacingTokens.x4l
                              : AppSpacingTokens.x5l) *
                          2),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          layout.maxContentWidth * (width < 600 ? 1 : 0.54),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: surface.canvas,
                        borderRadius: BorderRadius.circular(AppRadiusTokens.xl),
                        border: Border.all(color: surface.hairline),
                        boxShadow: AppShadowTokens.level4,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(layout.cardPaddingLarge),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: width < 600 ? 72 : 84,
                              height: width < 600 ? 72 : 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: <Color>[
                                    AppColorTokens.gradientDevelopStart,
                                    AppColorTokens.gradientDevelopEnd,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.wb_sunny_rounded,
                                size: width < 600 ? 34 : 38,
                                color: AppColorTokens.onPrimary,
                              ),
                            ),
                            SizedBox(height: layout.componentGap),
                            Text(
                              l10n?.todayHeroTitle ?? 'Today',
                              style: typography.displayLg.copyWith(
                                color: scheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacingTokens.xs),
                            Text(
                              l10n?.todayHeroDescription ??
                                  'The new home starts here: we are rebuilding the responsive visual system first, then layering in water tracking, reminders, health snapshots, and Lumi guidance.',
                              style: typography.bodyMd.copyWith(
                                color: surface.body,
                              ),
                            ),
                            const SizedBox(height: AppSpacingTokens.md),
                            Text(
                              session.isAuthenticated
                                  ? 'Signed in as ${session.user?.email ?? ''}'
                                  : session.isLoading
                                  ? 'Checking session...'
                                  : 'Not signed in yet.',
                              style: typography.bodySm.copyWith(
                                color: surface.mute,
                              ),
                            ),
                            const SizedBox(height: AppSpacingTokens.lg),
                            Wrap(
                              spacing: AppSpacingTokens.sm,
                              runSpacing: AppSpacingTokens.sm,
                              children: <Widget>[
                                _TodayPreviewChip(
                                  label: l10n?.todayChipWater ??
                                      'Water Tracking',
                                ),
                                _TodayPreviewChip(
                                  label: l10n?.todayChipMedication ??
                                      'Medication Reminders',
                                ),
                                _TodayPreviewChip(
                                  label: l10n?.todayChipSnapshot ??
                                      'Health Snapshot',
                                ),
                                _TodayPreviewChip(
                                  label: l10n?.todayChipDiet ??
                                      'Diet Suggestions',
                                ),
                                _TodayPreviewChip(
                                  label: l10n?.todayChipEnvironment ??
                                      'Environment Alerts',
                                ),
                                _TodayPreviewChip(
                                  label: l10n?.todayChipLumi ??
                                      'Lumi Guidance',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TodayPreviewChip extends StatelessWidget {
  const _TodayPreviewChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = MediaQuery.sizeOf(context).width < 600
        ? AppTypographyTokens.mobile(scheme.onSurface)
        : AppTypographyTokens.desktop(scheme.onSurface);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: surface.canvasSoft,
        borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
        border: Border.all(color: surface.hairline),
      ),
      child: Text(
        label,
        style: typography.bodySm.copyWith(color: scheme.onSurface),
      ),
    );
  }
}

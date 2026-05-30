import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/features/today/domain/entities/today_dashboard.dart';
import 'package:luminous/l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';

class TodayDashboardView extends StatelessWidget {
  const TodayDashboardView({super.key, required this.dashboard});

  final TodayDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final sections = <Widget>[
      _TodayTopBar(
        hasUnreadNotifications: dashboard.user.hasUnreadNotifications,
      ),
      const SizedBox(height: AppSpacingTokens.md),
      _TodayHero(moment: dashboard.user.moment),
      const SizedBox(height: AppSpacingTokens.md),
      _TodayWaterCard(water: dashboard.water),
      const SizedBox(height: AppSpacingTokens.sm),
      _TodayMedicationCard(medication: dashboard.medication),
      const SizedBox(height: AppSpacingTokens.sm),
      _TodayHealthSummaryCard(vitals: dashboard.vitals),
      const SizedBox(height: AppSpacingTokens.sm),
      _TodayMealSuggestionCard(mealSuggestion: dashboard.mealSuggestion),
      const SizedBox(height: AppSpacingTokens.sm),
      _TodayEnvironmentCard(environment: dashboard.environment),
      const SizedBox(height: AppSpacingTokens.sm),
      _TodayLumiCard(suggestion: dashboard.lumiSuggestion),
    ];

    return ListView(
      key: const PageStorageKey<String>('today-dashboard-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.sm,
        AppSpacingTokens.md,
        AppSpacingTokens.xl,
      ),
      children: [
        for (var index = 0; index < sections.length; index += 1)
          sections[index]
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 50 * index),
                duration: 320.ms,
              )
              .slideY(
                begin: 0.08,
                end: 0,
                delay: Duration(milliseconds: 50 * index),
                duration: 320.ms,
                curve: Curves.easeOutCubic,
              ),
      ],
    );
  }
}

class TodayLoadingView extends StatelessWidget {
  const TodayLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = theme.extension<AppThemeSurface>()!;

    return Shimmer.fromColors(
      baseColor: surface.canvas.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.42 : 1,
      ),
      highlightColor: surface.canvasSoft2,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacingTokens.md,
          AppSpacingTokens.sm,
          AppSpacingTokens.md,
          AppSpacingTokens.xl,
        ),
        children: const [
          _TodaySkeletonBlock(height: 44),
          SizedBox(height: AppSpacingTokens.md),
          _TodaySkeletonBlock(height: 126, radius: 28),
          SizedBox(height: AppSpacingTokens.md),
          _TodaySkeletonBlock(height: 178),
          SizedBox(height: AppSpacingTokens.sm),
          _TodaySkeletonBlock(height: 94),
          SizedBox(height: AppSpacingTokens.sm),
          _TodaySkeletonBlock(height: 96),
          SizedBox(height: AppSpacingTokens.sm),
          _TodaySkeletonBlock(height: 92),
          SizedBox(height: AppSpacingTokens.sm),
          _TodaySkeletonBlock(height: 82),
          SizedBox(height: AppSpacingTokens.sm),
          _TodaySkeletonBlock(height: 104),
        ],
      ),
    );
  }
}

class TodayErrorView extends StatelessWidget {
  const TodayErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacingTokens.md,
        AppSpacingTokens.lg,
        AppSpacingTokens.md,
        AppSpacingTokens.xl,
      ),
      children: [
        _TodayPanel(
          padding: const EdgeInsets.all(AppSpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.todayErrorTitle, style: typography.displaySm),
              const SizedBox(height: AppSpacingTokens.xs),
              Text(
                l10n.todayErrorDescription,
                style: typography.bodyMd.copyWith(color: surface.body),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              _TodayOutlineActionButton(
                label: l10n.todayRetryAction,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayTopBar extends StatelessWidget {
  const _TodayTopBar({required this.hasUnreadNotifications});

  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return Row(
      children: [
        Text(
          l10n.appTitle,
          style: typography.displaySm.copyWith(
            color: _TodayPalette.brand,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Tooltip(
          message: l10n.todayNotificationsTooltip,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: surface.canvas.withValues(alpha: 0.84),
                  borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
                  border: Border.all(color: surface.hairline),
                  boxShadow: AppShadowTokens.level2,
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: scheme.onSurface,
                    size: 20,
                  ),
                  visualDensity: VisualDensity.compact,
                  style: const ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
              if (hasUnreadNotifications)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: _TodayPalette.coralStrong,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayHero extends StatelessWidget {
  const _TodayHero({required this.moment});

  final TodayDayMoment moment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return Container(
      padding: const EdgeInsets.all(AppSpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _TodayPalette.mintSoft.withValues(alpha: 0.9),
            surface.canvas.withValues(alpha: 0.96),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greetingTitle(l10n, moment),
                  style: typography.displayMd.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacingTokens.xs),
                Text(
                  _greetingSubtitle(l10n, moment),
                  style: typography.bodyMd.copyWith(color: surface.body),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          const Flexible(
            child: Align(
              alignment: Alignment.topRight,
              child: _TodayMascotIllustration(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWaterCard extends StatelessWidget {
  const _TodayWaterCard({required this.water});

  final TodayWaterSummary water;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return _TodayPanel(
      key: const Key('today-water-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySectionHeader(title: l10n.todayWaterCardTitle),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _TodayWaterArc(
                  completedCount: water.completedCount,
                  targetCount: water.targetCount,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.todayWaterCount(water.completedCount),
                    style: typography.displayMd.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacingTokens.xxs),
                  Text(
                    l10n.todayWaterGoalCount(water.targetCount),
                    style: typography.bodySm.copyWith(color: surface.mute),
                  ),
                  const SizedBox(height: AppSpacingTokens.md),
                  Text(
                    l10n.todayWaterRemainingCount(water.remainingCount),
                    style: typography.bodyMdStrong.copyWith(
                      color: _TodayPalette.brand,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
            child: LinearProgressIndicator(
              value: water.progress,
              minHeight: 6,
              backgroundColor: surface.canvasSoft2,
              valueColor: const AlwaysStoppedAnimation<Color>(
                _TodayPalette.brand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayMedicationCard extends StatelessWidget {
  const _TodayMedicationCard({required this.medication});

  final TodayMedicationSummary medication;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return _TodayPanel(
      key: const Key('today-medication-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySectionHeader(
            title: l10n.todayMedicationCardTitle,
            trailing: _TodayOutlineActionButton(
              label: l10n.todayMedicationAction,
              onPressed: () {},
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _TodayPalette.brandSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.medication_liquid_rounded,
                  color: _TodayPalette.brand,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.todayMedicationSummary(
                        medication.medicineCount,
                        medication.pendingCount,
                      ),
                      style: typography.bodyMdStrong,
                    ),
                    const SizedBox(height: AppSpacingTokens.xs),
                    Text(
                      l10n.todayMedicationNextDose(
                        medication.nextDoseTimeLabel,
                        _medicationName(l10n, medication.nextMedicine),
                      ),
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TodayHealthSummaryCard extends StatelessWidget {
  const _TodayHealthSummaryCard({required this.vitals});

  final List<TodayVitalSummary> vitals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return _TodayPanel(
      key: const Key('today-health-summary-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySectionHeader(title: l10n.todayHealthSummaryCardTitle),
          const SizedBox(height: AppSpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: _TodayHealthMetric(
                  icon: Icons.favorite_rounded,
                  iconColor: _TodayPalette.coralStrong,
                  label: l10n.todayVitalHeartRateLabel,
                  value: _vitalValue(TodayVitalType.heartRate),
                  unitLabel: l10n.todayVitalHeartRateUnit,
                ),
              ),
              _TodayDivider(color: surface.hairline),
              Expanded(
                child: _TodayHealthMetric(
                  icon: Icons.monitor_heart_outlined,
                  iconColor: _TodayPalette.coralSoftText,
                  label: l10n.todayVitalBloodPressureLabel,
                  value: _vitalValue(TodayVitalType.bloodPressure),
                ),
              ),
              _TodayDivider(color: surface.hairline),
              Expanded(
                child: _TodayHealthMetric(
                  icon: Icons.bedtime_rounded,
                  iconColor: _TodayPalette.violetStrong,
                  label: l10n.todayVitalSleepLabel,
                  value: _vitalValue(TodayVitalType.sleep),
                  unitLabel: l10n.todayVitalSleepUnit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _vitalValue(TodayVitalType type) {
    for (final vital in vitals) {
      if (vital.type == type) {
        return vital.valueLabel;
      }
    }

    return '--';
  }
}

class _TodayMealSuggestionCard extends StatelessWidget {
  const _TodayMealSuggestionCard({required this.mealSuggestion});

  final TodayMealSuggestion mealSuggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    Widget rowLayout() {
      return Row(
        children: [
          const _TodayMealPlateIllustration(),
          const SizedBox(width: AppSpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _mealTitle(l10n, mealSuggestion.type),
                  style: typography.bodyMdStrong,
                ),
                const SizedBox(height: AppSpacingTokens.xxs),
                Text(
                  _mealDescription(l10n, mealSuggestion.type),
                  style: typography.bodySm.copyWith(color: surface.body),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacingTokens.sm),
          _TodayOutlineActionButton(
            label: l10n.todayMealRefreshAction,
            onPressed: () {},
          ),
        ],
      );
    }

    Widget compactLayout() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _TodayMealPlateIllustration(),
              const SizedBox(width: AppSpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mealTitle(l10n, mealSuggestion.type),
                      style: typography.bodyMdStrong,
                    ),
                    const SizedBox(height: AppSpacingTokens.xxs),
                    Text(
                      _mealDescription(l10n, mealSuggestion.type),
                      style: typography.bodySm.copyWith(color: surface.body),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: _TodayOutlineActionButton(
              label: l10n.todayMealRefreshAction,
              onPressed: () {},
            ),
          ),
        ],
      );
    }

    return _TodayPanel(
      key: const Key('today-meal-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySectionHeader(title: l10n.todayMealCardTitle),
          const SizedBox(height: AppSpacingTokens.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              return constraints.maxWidth < 320 ? compactLayout() : rowLayout();
            },
          ),
        ],
      ),
    );
  }
}

class _TodayEnvironmentCard extends StatelessWidget {
  const _TodayEnvironmentCard({required this.environment});

  final TodayEnvironmentSummary environment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _TodayPanel(
      key: const Key('today-environment-card'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TodaySectionHeader(
            title: l10n.todayEnvironmentCardTitle,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _TodayPalette.brand,
            ),
          ),
          const SizedBox(height: AppSpacingTokens.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              final chipWidth = constraints.maxWidth < 320
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppSpacingTokens.sm) / 2;

              return Wrap(
                spacing: AppSpacingTokens.sm,
                runSpacing: AppSpacingTokens.sm,
                children: [
                  for (final signal in environment.signals)
                    SizedBox(
                      width: chipWidth,
                      child: _TodayEnvironmentSignalChip(signal: signal),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TodayLumiCard extends StatelessWidget {
  const _TodayLumiCard({required this.suggestion});

  final TodayLumiSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    Widget action = _TodayOutlineActionButton(
      label: l10n.todayLumiAction,
      onPressed: () {},
    );

    return _TodayPanel(
      key: const Key('today-lumi-card'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_TodayPalette.brandSoft, surface.canvas],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: surface.hairline),
        boxShadow: AppShadowTokens.level3,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TodaySectionHeader(title: l10n.todayLumiCardTitle),
              const SizedBox(height: AppSpacingTokens.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: _TodayPalette.mintSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 21,
                      color: _TodayPalette.brand,
                    ),
                  ),
                  const SizedBox(width: AppSpacingTokens.sm),
                  Expanded(
                    child: Text(
                      _lumiBody(l10n, suggestion.type),
                      style: typography.bodyMd.copyWith(color: surface.body),
                    ),
                  ),
                ],
              ),
            ],
          );

          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: AppSpacingTokens.sm),
                Align(alignment: Alignment.centerRight, child: action),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: content),
              const SizedBox(width: AppSpacingTokens.sm),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _TodayPanel extends StatelessWidget {
  const _TodayPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacingTokens.md),
    this.decoration,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return DecoratedBox(
      decoration:
          decoration ??
          BoxDecoration(
            color: surface.canvas,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: surface.hairline),
            boxShadow: AppShadowTokens.level3,
          ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _TodaySectionHeader extends StatelessWidget {
  const _TodaySectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: typography.bodyMdStrong.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _TodayOutlineActionButton extends StatelessWidget {
  const _TodayOutlineActionButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _TodayPalette.brand,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: _TodayPalette.brandSoftLine),
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacingTokens.sm,
          vertical: AppSpacingTokens.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadiusTokens.pillSm),
        ),
        textStyle: typography.buttonMd,
      ),
      child: Text(label),
    );
  }
}

class _TodayWaterArc extends StatelessWidget {
  const _TodayWaterArc({
    required this.completedCount,
    required this.targetCount,
  });

  final int completedCount;
  final int targetCount;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final cupWidth = width < 160 ? 16.0 : 18.0;
        final cupHeight = width < 160 ? 24.0 : 28.0;
        final radius = math.min(width * 0.34, 54.0);
        const topOffset = 2.0;
        final centerX = width / 2;

        return SizedBox(
          height: cupHeight + radius + 14,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _TodayArcPainter(color: surface.hairline),
                  ),
                ),
              ),
              for (var index = 0; index < targetCount; index += 1)
                Builder(
                  builder: (context) {
                    final denominator = targetCount == 1 ? 1 : targetCount - 1;
                    final t = index / denominator;
                    final angle = (math.pi * 0.12) + (math.pi * 0.76 * t);
                    final x = centerX + math.cos(angle) * radius;
                    final y = topOffset + (1 - math.sin(angle)) * radius;

                    return Positioned(
                      left: x - (cupWidth / 2),
                      top: y,
                      child: Transform.rotate(
                        angle: (t - 0.5) * 0.3,
                        child: _TodayWaterCup(
                          width: cupWidth,
                          height: cupHeight,
                          filled: index < completedCount,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TodayHealthMetric extends StatelessWidget {
  const _TodayHealthMetric({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unitLabel,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unitLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: iconColor),
              const SizedBox(width: AppSpacingTokens.xs),
              Expanded(
                child: Text(
                  label,
                  style: typography.bodySm.copyWith(color: surface.body),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacingTokens.xs),
          RichText(
            text: TextSpan(
              style: typography.displaySm.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              children: [
                TextSpan(text: value),
                if (unitLabel != null && unitLabel!.isNotEmpty)
                  TextSpan(
                    text: ' $unitLabel',
                    style: typography.bodySm.copyWith(color: surface.body),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayEnvironmentSignalChip extends StatelessWidget {
  const _TodayEnvironmentSignalChip({required this.signal});

  final TodayEnvironmentSignal signal;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final typography = AppTypographyTokens.mobile(scheme.onSurface);
    final surface = Theme.of(context).extension<AppThemeSurface>()!;
    final accent = _environmentAccent(signal.type);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacingTokens.sm,
        vertical: AppSpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(_environmentIcon(signal.type), size: 18, color: accent),
          const SizedBox(width: AppSpacingTokens.xs),
          Expanded(
            child: Text(
              _environmentLabel(l10n, signal.type),
              style: typography.bodySmStrong,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacingTokens.xs),
          Text(
            _environmentLevelLabel(l10n, signal.level),
            style: typography.bodySm.copyWith(color: surface.body),
          ),
        ],
      ),
    );
  }
}

class _TodayDivider extends StatelessWidget {
  const _TodayDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: color);
  }
}

class _TodayWaterCup extends StatelessWidget {
  const _TodayWaterCup({
    required this.width,
    required this.height,
    required this.filled,
  });

  final double width;
  final double height;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.fromLTRB(
        width * 0.14,
        height * 0.18,
        width * 0.14,
        height * 0.12,
      ),
      decoration: BoxDecoration(
        color: filled
            ? _TodayPalette.brandSoft.withValues(alpha: 0.7)
            : surface.canvas.withValues(alpha: 0.74),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(width * 0.22),
          bottom: Radius.circular(width * 0.32),
        ),
        border: Border.all(
          color: filled
              ? _TodayPalette.brand.withValues(alpha: 0.38)
              : surface.hairlineStrong.withValues(alpha: 0.28),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: filled ? height * 0.44 : height * 0.08,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: filled
                  ? const [_TodayPalette.waterTop, _TodayPalette.waterBottom]
                  : [surface.canvasSoft2, surface.canvasSoft2],
            ),
            borderRadius: BorderRadius.circular(width * 0.24),
          ),
        ),
      ),
    );
  }
}

class _TodayMascotIllustration extends StatelessWidget {
  const _TodayMascotIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x66D7FFF2), Color(0x00D7FFF2)],
              ),
            ),
          ),
          Positioned(
            top: 8,
            left: 16,
            child: Transform.rotate(
              angle: -0.55,
              child: Container(
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  color: _TodayPalette.mintStrong.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 16,
            child: Transform.rotate(
              angle: 0.55,
              child: Container(
                width: 24,
                height: 32,
                decoration: BoxDecoration(
                  color: _TodayPalette.mintStrong.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFEFFFF9), Color(0xFFBDF9E9)],
              ),
            ),
          ),
          Positioned(
            top: 22,
            child: Container(
              width: 16,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFE0FFF7),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Positioned(left: 22, top: 30, child: _faceDot()),
          Positioned(right: 22, top: 30, child: _faceDot()),
          Positioned(
            bottom: 18,
            child: Container(
              width: 18,
              height: 10,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFF57A391), width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _faceDot() {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(
        color: Color(0xFF53A18D),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TodayMealPlateIllustration extends StatelessWidget {
  const _TodayMealPlateIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: AppShadowTokens.level2,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFEED7), Color(0xFFFFFFFF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: const Color(0xFFF3E7D8)),
          ),
          child: Stack(
            children: const [
              Positioned(
                left: 12,
                top: 14,
                child: _FoodBlob(
                  width: 18,
                  height: 14,
                  color: Color(0xFF92C25F),
                ),
              ),
              Positioned(
                left: 25,
                top: 18,
                child: _FoodBlob(
                  width: 16,
                  height: 12,
                  color: Color(0xFFE5A24F),
                ),
              ),
              Positioned(
                right: 12,
                top: 18,
                child: _FoodBlob(
                  width: 17,
                  height: 13,
                  color: Color(0xFF76B86B),
                ),
              ),
              Positioned(
                left: 18,
                bottom: 14,
                child: _FoodBlob(
                  width: 22,
                  height: 14,
                  color: Color(0xFFD98352),
                ),
              ),
              Positioned(
                right: 14,
                bottom: 16,
                child: _FoodBlob(
                  width: 18,
                  height: 12,
                  color: Color(0xFFB0D56A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodBlob extends StatelessWidget {
  const _FoodBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.45,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _TodaySkeletonBlock extends StatelessWidget {
  const _TodaySkeletonBlock({required this.height, this.radius = 24});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).extension<AppThemeSurface>()!;

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: surface.canvas,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _TodayArcPainter extends CustomPainter {
  const _TodayArcPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.92)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.06,
        size.width * 0.88,
        size.height * 0.92,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TodayArcPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

abstract final class _TodayPalette {
  static const Color brand = Color(0xFF0FAF94);
  static const Color brandSoft = Color(0xFFE7FBF5);
  static const Color brandSoftLine = Color(0xFF8EDFCF);
  static const Color mintSoft = Color(0xFFE9FFF6);
  static const Color mintStrong = Color(0xFF9DEDD8);
  static const Color coralStrong = Color(0xFFFF6D6B);
  static const Color coralSoftText = Color(0xFFE76A6A);
  static const Color violetStrong = Color(0xFF7068F3);
  static const Color amber = Color(0xFFFFA43A);
  static const Color waterTop = Color(0xFF8CE9DC);
  static const Color waterBottom = Color(0xFF1BB59D);
}

String _greetingTitle(AppLocalizations l10n, TodayDayMoment moment) {
  return switch (moment) {
    TodayDayMoment.morning => l10n.todayGreetingTitleMorning,
    TodayDayMoment.afternoon => l10n.todayGreetingTitleAfternoon,
    TodayDayMoment.evening => l10n.todayGreetingTitleEvening,
  };
}

String _greetingSubtitle(AppLocalizations l10n, TodayDayMoment moment) {
  return switch (moment) {
    TodayDayMoment.morning => l10n.todayGreetingSubtitleMorning,
    TodayDayMoment.afternoon => l10n.todayGreetingSubtitleAfternoon,
    TodayDayMoment.evening => l10n.todayGreetingSubtitleEvening,
  };
}

String _medicationName(AppLocalizations l10n, TodayMedicationKind kind) {
  return switch (kind) {
    TodayMedicationKind.atorvastatin => l10n.todayMedicationNameAtorvastatin,
  };
}

String _mealTitle(AppLocalizations l10n, TodayMealSuggestionType type) {
  return switch (type) {
    TodayMealSuggestionType.highProteinBalancedLunch =>
      l10n.todayMealHighProteinBalancedTitle,
  };
}

String _mealDescription(AppLocalizations l10n, TodayMealSuggestionType type) {
  return switch (type) {
    TodayMealSuggestionType.highProteinBalancedLunch =>
      l10n.todayMealHighProteinBalancedDescription,
  };
}

String _environmentLabel(
  AppLocalizations l10n,
  TodayEnvironmentSignalType type,
) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => l10n.todayEnvironmentPollenLabel,
    TodayEnvironmentSignalType.uv => l10n.todayEnvironmentUvLabel,
  };
}

String _environmentLevelLabel(
  AppLocalizations l10n,
  TodayEnvironmentLevel level,
) {
  return switch (level) {
    TodayEnvironmentLevel.low => l10n.todayEnvironmentLevelLow,
    TodayEnvironmentLevel.medium => l10n.todayEnvironmentLevelMedium,
    TodayEnvironmentLevel.high => l10n.todayEnvironmentLevelHigh,
  };
}

IconData _environmentIcon(TodayEnvironmentSignalType type) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => Icons.local_florist_outlined,
    TodayEnvironmentSignalType.uv => Icons.wb_sunny_outlined,
  };
}

Color _environmentAccent(TodayEnvironmentSignalType type) {
  return switch (type) {
    TodayEnvironmentSignalType.pollen => _TodayPalette.brand,
    TodayEnvironmentSignalType.uv => _TodayPalette.amber,
  };
}

String _lumiBody(AppLocalizations l10n, TodayLumiSuggestionType type) {
  return switch (type) {
    TodayLumiSuggestionType.pollenProtection =>
      l10n.todayLumiPollenProtectionBody,
  };
}

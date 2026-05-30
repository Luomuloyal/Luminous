import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luminous/core/design/app_design.dart';
import 'package:luminous/core/theme/app_theme_extensions.dart';
import 'package:luminous/core/widgets/page_scaffold_shell.dart';
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

    return PageScaffoldShell(
      title: l10n?.todayHeroTitle ?? 'Today',
      description:
          l10n?.todayHeroDescription ??
          'The new home starts here: we are rebuilding the responsive visual system first, then layering in water tracking, reminders, health snapshots, and Lumi guidance.',
      actions: [
        if (!session.isAuthenticated)
          OutlinedButton(
            onPressed: () => context.push('/login'),
            child: Text(l10n?.authGoLogin ?? 'Sign in'),
          ),
        if (!session.isAuthenticated)
          FilledButton(
            onPressed: () => context.push('/register'),
            child: Text(l10n?.authGoRegister ?? 'Create account'),
          ),
        if (session.isAuthenticated)
          FilledButton(
            onPressed: () async {
              await ref.read(authSessionProvider.notifier).logout();
            },
            child: Text(l10n?.authSignOut ?? 'Sign out'),
          ),
      ],
      children: [
        PageSectionCard(
          title: l10n?.todaySectionTitle ?? 'Today workspace',
          subtitle:
              l10n?.todaySectionSubtitle ??
              'The new home will gradually attach reminders, snapshots, water tracking, and Lumi guidance here.',
          child: Column(
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
              const SizedBox(height: AppSpacingTokens.lg),
              Text(
                session.isAuthenticated
                    ? (l10n?.authSignedInAs(session.user?.email ?? '') ??
                        'Signed in as ${session.user?.email ?? ''}')
                    : session.isLoading
                    ? (l10n?.authCheckingSession ?? 'Checking session...')
                    : (l10n?.authNotSignedIn ?? 'Not signed in yet.'),
                style: typography.bodySm.copyWith(color: surface.mute),
              ),
              const SizedBox(height: AppSpacingTokens.lg),
              Wrap(
                spacing: AppSpacingTokens.sm,
                runSpacing: AppSpacingTokens.sm,
                children: <Widget>[
                  _TodayPreviewChip(
                    label: l10n?.todayChipWater ?? 'Water Tracking',
                  ),
                  _TodayPreviewChip(
                    label:
                        l10n?.todayChipMedication ?? 'Medication Reminders',
                  ),
                  _TodayPreviewChip(
                    label: l10n?.todayChipSnapshot ?? 'Health Snapshot',
                  ),
                  _TodayPreviewChip(
                    label: l10n?.todayChipDiet ?? 'Diet Suggestions',
                  ),
                  _TodayPreviewChip(
                    label:
                        l10n?.todayChipEnvironment ?? 'Environment Alerts',
                  ),
                  _TodayPreviewChip(
                    label: l10n?.todayChipLumi ?? 'Lumi Guidance',
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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

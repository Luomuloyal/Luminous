# Luminous UI Plan

Last updated: 2026-05-30

Current timeline: `MigrationLog.md`. Product stage: `../Lucent/docs/public/ROADMAP.md`.

## Baseline

- Five-tab shell: `today / record / medicine / mine / more`
- Responsive design tokens
- Lucent OpenAPI client
- Flutter `gen-l10n`
- Auth datasource / session / login / register providers
- Login / Register pages
- Persisted `system / light / dark` theme preference foundation
- Mobile bottom nav + desktop rail
- Today mobile-first mock dashboard UI with repository/provider boundary

Not restored yet: medicine loop, reminders, scan/upload, settings, theme selection UI, real feature data.

## UI Priority

1. Connect Today mock data to API-ready datasource/repository implementations.
2. Upgrade `record / medicine / mine / more` from placeholders to usable skeletons.
3. Add a Mine/settings theme selector for `system / light / dark`.
4. Rebuild medicine / reminder flows.
5. Add palette variants after the fixed-token surfaces have been reduced.

## Rules

- Use `lib/core/design/`, `lib/core/theme/`, `lib/core/constants/app_breakpoints.dart`.
- Read app theme mode from `appThemeControllerProvider`; do not hardcode `ThemeMode.system` in app entrypoints.
- Use `Theme.of(context).colorScheme` and `AppThemeSurface` for theme-aware surfaces before adding palette variants.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Put user-visible text in ARB files.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## Verify

```bash
flutter analyze
flutter test
```

For responsive UI, also check mobile overflow, desktop spacing, and zh/en text fit.

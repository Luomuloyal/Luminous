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
- Mobile bottom nav + desktop rail

Not restored yet: medicine loop, reminders, scan/upload, settings, real feature data.

## UI Priority

1. Split Today into section components.
2. Add Today mock provider.
3. Upgrade `record / medicine / mine / more` from placeholders to usable skeletons.
4. Rebuild medicine / reminder flows.

## Rules

- Use `lib/core/design/`, `lib/core/theme/`, `lib/core/constants/app_breakpoints.dart`.
- Put protocol logic in `lib/core/network/`, not `utils`.
- Put user-visible text in ARB files.
- Do not revive old `home / drug / scan / settings` pages wholesale.

## Verify

```bash
flutter analyze
flutter test
```

For responsive UI, also check mobile overflow, desktop spacing, and zh/en text fit.

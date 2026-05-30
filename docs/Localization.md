# Flutter i18n

Last updated: 2026-05-30

## Files

- Config: `l10n.yaml`
- ARB: `lib/l10n/app_zh.arb`, `lib/l10n/app_en.arb`
- Generated: `lib/l10n/app_localizations*.dart`

## Current Scope

- App title, tabs, Today dashboard, placeholders
- Login / Register / Forgot Password / Change Email / AuthShell
- Auth empty-field toast prompts
- Network `Accept-Language`

## Add Text

1. Add keys to both ARB files.
2. Run `flutter gen-l10n`.
3. Read via `AppLocalizations.of(context)`.

Do not hardcode user-visible text in pages.

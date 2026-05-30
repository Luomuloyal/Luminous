# AGENTS.md - Luminous

## Stack

- Flutter
- Riverpod, not GetX
- GoRouter, not `Navigator.push(MaterialPageRoute(...))`
- Backend: Lucent

## Commands

```bash
flutter pub get
flutter analyze
flutter test
```

Regenerate Lucent client:

```bash
cd ../Lucent && pnpm export:openapi
cd ../Luminous
npx @openapitools/openapi-generator-cli generate -g dart-dio -i ../Lucent/docs/openapi.json -o packages/lucent_openapi --additional-properties=serializationLibrary=json_serializable,pubName=lucent_openapi,pubLibrary=lucent_openapi,sourceFolder=src,finalProperties=true,skipCopyWith=true,useEnumExtension=true,enumUnknownDefaultCase=true
cd packages/lucent_openapi && dart pub get && dart run build_runner build --delete-conflicting-outputs
cd ../.. && flutter pub get
```

## Guardrails

- New code goes under `lib/features/`, `lib/core/`, or `lib/shared/`.
- Do not add code to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, `lib/components/`.
- API contract: `../Lucent/docs/public/api-contract.md`.
- Auth API details: `../Lucent/docs/auth-api-mock.md`.
- Network code belongs in `lib/core/network/`.
- User-visible text goes through ARB + `flutter gen-l10n`.
- Token storage prefers secure storage, with desktop/web fallback.

## Docs

- Read `docs/README.md` before editing docs.
- Frontend code changed: update `docs/MigrationLog.md`.
- Network / OpenAPI / auth client changed: update `docs/OpenApi_Client.md`.
- Visible text or l10n flow changed: update `docs/Localization.md`.
- UI plan changed: update `docs/UI_Implementation_Plan.md`.
- `docs/RestartPlan.md` and `docs/MigrationLog_Archive_PreReset.md` are reference only.

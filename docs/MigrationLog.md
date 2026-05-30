# Luminous Migration Log

Last updated: 2026-05-30

Records changes after the full reset only. Pre-reset history: `MigrationLog_Archive_PreReset.md`.

## 2026-05-30

### Reset Baseline

- Kept five-tab shell: `today / record / medicine / mine / more`.
- Removed old business pages, old utilities, old infra, and legacy backend coupling.
- Kept minimal runnable Flutter mainline.

### OpenAPI Client

- Generated Lucent client into `packages/lucent_openapi/`.
- Added wrapper/export under `lib/core/network/`.

### Design Tokens

- Added color, type, radius, spacing, shadow, layout, and breakpoint tokens.
- Wired tokens into shell, Today, placeholders, and theme extensions.

### i18n

- Added `l10n.yaml`, zh/en ARB files, and generated localizations.
- Moved app title, tabs, Today, placeholders, Login, Register, and AuthShell text to l10n.

### Network

- Added base URL, envelope, result code, API exception, session store, and providers.
- Added token injection, `Accept-Language`, `401002` refresh/retry, and Dio error unwrapping.

### Auth UI

- Added auth domain/session mapping, remote datasource, providers, LoginPage, RegisterPage, and AuthShell.
- Registered `/login` and `/register`.
- Added login/register/logout entry points from Today.

### Responsive Shell

- Added `ResponsiveContentFrame` and `PageScaffoldShell`.
- Mobile uses bottom navigation; desktop/web uses navigation rail.
- Today and four placeholder tabs use the shared page shell.

### Lucent Alignment

- Aligned token-expired handling with `401002`.
- Lucent fallback language is `en`.
- API docs now define `Accept-Language`.

### Security / E2E Fixes

- Lucent login now requires exactly one credential: `password` or `code`.
- Soft-deleted users are excluded from default lookups.
- Fixed JWT `sub` / `subject` duplication.
- Fixed i18n type output for test/dist.
- `pnpm test:e2e` passes with Docker PostgreSQL running.

### Docs

- Added `docs/README.md` as the frontend doc map.
- Marked reset/history docs as reference only.
- Unified API contract path to `../Lucent/docs/public/api-contract.md`.

## Verified

```bash
flutter gen-l10n
flutter analyze
flutter test

cd ../Lucent
pnpm build
pnpm test
pnpm test:e2e
```

## Next

1. Split Today into section components.
2. Add a Today mock provider.
3. Upgrade `record / medicine / mine / more` skeletons.
4. Rebuild medicine / reminder flows.

# Luminous Optimization and Nest Migration Plan

Last updated: 2026-05-24

## Goal

Luminous is already functional, and the current checks pass. The next work should focus on turning it from a demo-friendly app into a durable product:

1. Remove demo behavior from real user flows.
2. Make user data ownership and auth boundaries explicit.
3. Reduce heavy client-side work, especially the offline medicine database.
4. Prepare the backend for a Nest migration without breaking the current Flutter app.

This plan is intentionally incremental. Each phase should leave the app runnable and covered by targeted checks.

## Migration Guardrails

- Keep each migration slice small and reversible. Finish one state or structure adjustment, verify it, then move on.
- Start moving new Flutter code toward the target structure instead of extending the old layer-based layout indefinitely:

```text
lib/
  core/
  shared/
  features/
```

- Control file size during migration: target under 300 lines per file, 300-600 lines is acceptable, and anything above 600 lines should be split before more logic is added.
- Prefer migrating single-responsibility UI/session state first, then move to larger auth or business state after the smaller slice is stable.

## Current Baseline

Verified before this plan:

- `flutter analyze`: pass
- `flutter test`: pass
- `backend npm test`: pass
- `backend npm run build`: pass

Important current architecture notes:

- Flutter uses GetX controllers at page level and `DioRequest` as the unified HTTP entry.
- Backend is Express + TypeScript with route handlers under `backend/src/handlers`.
- AI calls are already centralized under `backend/src/ai`, with LangChain-compatible helper contracts.
- The API envelope is unified as `{ code, msg, result }`.
- The frontend still sends `userId` in several user-scoped requests.

## Phase 0: Structure Baseline and File Decomposition

Phase 0 comes before any new product-facing migration slice. The current priority is to make the codebase structurally safe to keep evolving:

1. Move new code into the target directory structure instead of extending legacy folders.
2. Split oversized files before adding more behavior.
3. Keep all structural changes low-risk, reversible, and behavior-preserving.

### 0.1 Directory contract

Frontend target direction:

```text
lib/
  core/
    providers/
    router/
    startup/
    theme/
  shared/
    widgets/
    layout/
  features/
    settings/
      presentation/
      providers/
      data/
    home/
    search/
    scan/
    reminders/
    auth/
```

Backend target direction during the pre-Nest cleanup period:

```text
backend/src/
  ai/
  auth/
  medicines/
  reminders/
  scan-records/
  users/
  shared/
    config/
    http/
  db/
```

Rules:

- `core` is for global runtime capabilities only.
- `shared` is for cross-feature reusable UI or helpers used by at least two features.
- `features` owns business-specific presentation/state/data code.
- Legacy folders may keep thin compatibility wrappers during migration, but new logic should not keep accumulating there.

### 0.2 File decomposition rules

Tasks:

- Split files larger than 600 lines before adding new logic to them.
- Prefer semantic splits such as `page`, `section`, `card`, `dialog`, `controller_support`, and `labels`, not arbitrary `part1/part2` buckets.
- Land the split first, then move files into the target directory structure in the same slice when the move is low-risk.
- Allow temporary export wrappers from old paths when they reduce migration blast radius.
- Do not combine structure migration with behavior changes unless the behavior fix is required to keep the app compiling or tested.

Acceptance:

- The app still builds and runs after each slice.
- `flutter analyze` stays green after each frontend slice.
- Relevant focused tests pass after each slice, and full regression gates run regularly.
- Large files shrink, and the new target directories become the canonical home for migrated code.

### 0.3 Recommended slice order

1. `Settings`: split `settings.dart`, move the page stack into `lib/features/settings/`.
2. `Main shell`: split `MainPage`, bottom bar, and ornament rendering responsibilities.
3. `Home`: separate page composition from home-specific presentation widgets.
4. `Search`: separate search page, history, empty state, and result rendering.
5. `Scan`: split page orchestration from action tiles, preview, and result presentation.
6. `Backend auth`: split the large Express auth handler into smaller module-scoped files without starting Nest yet.

### 0.4 Exit criteria

Phase 0 is considered healthy enough to move faster only when:

- the main oversized frontend files have been split into readable units;
- at least the first active UI modules have a real `features/*` home;
- old paths are reduced to compatibility shells or removed where safe;
- the backend no longer depends on one large auth handler file;
- the repo remains green on the default validation gates.

## Phase 1: Product Trust and Real Data

### 1.1 Remove real-flow demo data

Problem:

- Reminder and home flows still contain demo fallback behavior.
- Empty reminder lists can currently trigger seeded default reminders.
- A real user should not see or receive data they did not create.

Tasks:

- Stop auto-creating default reminder plans in `ReminderListController`.
- Keep demo content only for explicit guest/dev/demo states.
- For logged-in users with no data, show empty states and clear calls to action.
- Update tests for empty reminder lists and non-seeding behavior.

Acceptance:

- A newly registered user with no reminders sees an empty reminder state.
- No backend reminder is created unless the user explicitly creates one.
- `flutter test` continues to pass.

### 1.2 Session expiration and token storage

Problem:

- Tokens are stored in `SharedPreferences`.
- Refresh failure clears tokens but does not consistently clear the in-memory user session.

Tasks:

- Introduce secure token storage with `flutter_secure_storage`.
- Add a single session-expired path in `DioRequest` or a small session service.
- On refresh failure, clear tokens, clear `UserController`, and notify the UI once.
- Avoid repeated session-expired toasts from concurrent requests.

Acceptance:

- Expired refresh token returns the app to a clean logged-out state.
- User-scoped pages do not continue showing stale logged-in state.
- Existing login tests still pass, with new token/session tests added.

## Phase 2: Auth Boundary and API Ownership

### 2.1 Protect user-scoped backend routes

Problem:

- `authMiddleware` exists but is not used on most user-scoped routes.
- User ownership is currently inferred from request body `userId`.

Tasks:

- Apply `authMiddleware` to user profile, my medicines, reminders, and scan-record routes.
- Derive `userId` from JWT for protected handlers.
- Temporarily accept body `userId` only where compatibility is needed, and assert it matches the JWT user.
- Return consistent `401/403` envelopes for missing or mismatched identity.

Acceptance:

- A user cannot read or modify another user's reminders or medicines by changing body `userId`.
- Existing Flutter calls continue to work after adding Authorization headers.
- Backend tests cover mismatched user identity.

### 2.2 Frontend contract cleanup

Tasks:

- Stop sending `userId` from Flutter for protected endpoints after backend compatibility is in place.
- Keep public endpoints public: medicine search/detail, AI detail/safety if product direction allows anonymous use.
- Update `docs/lib-docs/frontend-backend-alignment-checklist.md`.

Acceptance:

- Frontend user-scoped APIs no longer depend on locally supplied `userId`.
- Contract docs match route behavior.

## Phase 3: Offline Medicine Search Performance

Problem:

- `lib/assets/data.json` is about 52 MB.
- `LocalMedicineStore` loads and decodes the whole JSON asset, then scans it linearly.

Preferred direction:

- Replace the JSON fallback search with a prebuilt local SQLite database using FTS.

Tasks:

- Add a build/import script that converts the medicine source data into a compact SQLite asset.
- Move local search to SQLite queries instead of full JSON decode.
- Keep the same `MedicineSearchResult` contract.
- Load the local database lazily and off the startup path.

Acceptance:

- First offline search no longer decodes a 52 MB JSON file on the UI isolate.
- Offline search still supports product name, approval number, manufacturer, holder, drug code, and serial number.
- Add tests for local search query behavior.

## Phase 4: Backend Migration to Nest

The Nest migration should be a controlled architecture migration, not a product rewrite.

### 4.1 Migration strategy

Use a parallel Nest backend first, then switch routes gradually.

Recommended structure:

```text
backend-nest/
  src/
    main.ts
    app.module.ts
    common/
      filters/
      interceptors/
      guards/
      dto/
    config/
    auth/
    medicines/
    reminders/
    my-medicines/
    scan-records/
    ai/
    db/
```

Key compatibility rules:

- Preserve the current route paths under `/api/*`.
- Preserve the response envelope `{ code, msg, result }`.
- Preserve existing JWT token semantics until Flutter no longer depends on them.
- Reuse the current AI helper contracts where possible.

### 4.2 Suggested Nest module mapping

- `auth`: login, register, refresh, user profile, verification code delivery.
- `medicines`: search, detail, AI detail, AI safety, scan recognition.
- `my-medicines`: user medicine collection.
- `reminders`: reminder plans and today reminders.
- `scan-records`: scan history create/list.
- `ai`: LangChain gateway, prompt builders, text cache.
- `db`: Mongo, MySQL, Redis providers.
- `common`: response envelope, error mapping, auth guard, validation pipes.

### 4.3 Migration phases

1. Scaffold Nest app and duplicate health check.
2. Move shared config/env parsing into Nest config providers.
3. Move AI module first because it is already centralized and testable.
4. Move medicine public routes.
5. Move auth and JWT guard.
6. Move user-scoped routes after Phase 2 auth rules are already tested.
7. Run Express and Nest parity tests before switching deployment.

Acceptance:

- Flutter does not need route changes during the migration.
- Express tests have equivalent Nest tests before a route is switched.
- Docker and deployment docs clearly state which backend entrypoint is active.

## Phase 5: Testing and Performance Baseline

Tasks:

- Add `integration_test` flows for login, scan-to-detail, reminder-create-to-checkin.
- Add a profile-mode performance baseline for cold start and local search.
- Keep `flutter analyze`, `flutter test`, `backend npm test`, and backend build as the default gate.

## Working Rules

- Make one product-visible change at a time.
- Update tests and docs in the same phase when behavior changes.
- Avoid broad refactors unless they unlock the current phase.
- Keep the app shippable after each completed slice.

## Progress Log

### 2026-05-23

- Added this optimization and Nest migration plan.
- Phase 1.1 started: `ReminderListController` no longer seeds default reminder plans when the logged-in user's local reminder list is empty.
- Added a controller test to keep empty reminder lists empty after local load and remote sync.
- Moved ornament session/UI state from `OrnamentController` to a Riverpod notifier under `lib/core/theme/ornaments/`, keeping this migration slice small and aligned with the target directory structure.
- Started `UserController` migration by moving session restore and persisted user reads/writes into `lib/features/auth/`, while keeping the old controller API as the compatibility layer for existing pages.
- Replaced the runtime `UserController` bridge with a temporary global `ProviderContainer` bridge for legacy GetX controllers that cannot yet receive `WidgetRef`.
- Expanded read-side adoption across Home, reminders, check-in, album, search, scan, settings/profile, and Mine controllers so session reads come from `currentUserProvider` / `userSessionReadyProvider`.
- Marked the deprecated `SplashPage` as unused and verified it is not connected to the active GoRouter route table.

### 2026-05-24

- Added `Phase 0` to prioritize directory structure cleanup and oversized file decomposition before resuming faster product-facing migration.
- Set the recommended structure-first execution order to `Settings -> Main shell -> Home -> Search -> Scan -> backend auth`.
- Started the first structural slice by moving the Settings presentation code toward `lib/features/settings/` while keeping compatibility with existing imports.

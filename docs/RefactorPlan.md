# Luminous Optimization and Nest Migration Plan

Last updated: 2026-05-24

## Goal

Luminous is already functional, and the current checks pass. The next work should focus on turning it from a demo-friendly app into a durable product:

1. Remove demo behavior from real user flows.
2. Make user data ownership and auth boundaries explicit.
3. Reduce heavy client-side work, especially the offline medicine database.
4. Prepare the backend for a NestJS + PostgreSQL migration without breaking the current Flutter app.

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
- The current backend data stores are MongoDB + MySQL + Redis.
- AI calls are already centralized under `backend/src/ai`, with LangChain-compatible helper contracts.
- The API envelope is unified as `{ code, msg, result }`.
- The frontend still sends `userId` in several user-scoped requests.

Target backend end-state for this plan:

- Framework: NestJS.
- Primary data store: PostgreSQL.
- Optional Redis: keep only where short-lived cache, verification code storage, or AI/text cache materially helps.
- MongoDB and MySQL are migration sources to retire, not long-term dependencies to preserve.

## Phase 0: Structure Baseline and File Decomposition

Phase 0 comes before any new product-facing migration slice. The current priority is to make the codebase structurally safe to keep evolving:

1. Move new code into the target directory structure instead of extending legacy folders.
2. Split oversized files before adding more behavior.
3. Keep all structural changes low-risk, reversible, and behavior-preserving.

Phase 0 is scoped to the Flutter project base. Backend restructuring stays documented in later phases, but Express auth splitting, NestJS scaffolding, and PostgreSQL work should not start until the Flutter directory structure and shared UI foundation are healthy.

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

1. `Settings`: split `settings.dart`, move the page stack into `lib/features/settings/`. Completed on 2026-05-24.
2. `Main shell`: split `MainPage`, bottom bar, and ornament rendering responsibilities. Completed on 2026-05-24.
3. `Home`: separate page composition from home-specific presentation widgets, and make `HomePage` the canonical feature entry while keeping `HomeView` as a thin compatibility shell. Completed on 2026-05-24.
4. `Search`: separate search page, history, empty state, and result rendering, and make `SearchPage` the canonical feature entry while keeping `SearchView` as a thin compatibility shell. Completed on 2026-05-24.
5. `Scan`: split page orchestration from action tiles, preview, and result presentation. Completed on 2026-05-24.
6. `Shared UI base`: move genuinely cross-feature UI from `lib/components/` into `lib/shared/widgets/` or `lib/shared/layout/`, keeping old component files as compatibility exports where useful. Started on 2026-05-24.
7. `Auth presentation`: split login/register pages and auth widgets into `lib/features/auth/presentation/` without changing token/session behavior.
8. `Medicine detail`: split `medicine_detail.dart` and drug presentation widgets into a feature-owned presentation layer without changing API contracts.
9. `Reminders presentation`: split reminder list/edit pages into feature-owned page, section, card, and form files without changing reminder data behavior.
10. `Safety and Mine`: move remaining active page shells toward feature ownership after the shared UI base is stable.

### 0.4 Exit criteria

Phase 0 is considered healthy enough to move faster only when:

- the main oversized frontend files have been split into readable units;
- at least the first active UI modules have a real `features/*` home;
- old paths are reduced to compatibility shells or removed where safe;
- shared UI that is used across multiple features has a canonical home under `lib/shared`;
- responsive layout primitives exist under `lib/shared/layout` or `lib/shared/widgets` so phone, tablet, desktop, and web variants can be added without rewriting feature pages;
- the repo remains green on the default validation gates.

### 0.5 Responsive readiness checkpoint

Current status on 2026-05-24:

- The refactor has preserved useful responsive seams at the feature and widget level. Migrated pages now have feature-owned entry points such as `HomePage`, `SearchPage`, and `MedicineScanPage`, which makes it possible to add compact, medium, and expanded variants inside each feature later.
- `lib/shared/widgets/responsive_quick_grid.dart` already centralizes one compact breakpoint at `600dp`, text-scale-aware quick-entry metrics, and `ResponsiveQuickWrap`.
- Home, Drug, and Mine quick-entry sections already consume the shared responsive quick-grid primitives instead of hardcoding fixed card widths.
- Settings theme style selection already uses local `500dp` and `720dp` breakpoints to change column count.
- Several remaining legacy pages use `LayoutBuilder` or `Wrap` for local compact handling, including Album, Drug detail, Reminders, CheckIn, Safety, and Mine.
- `test/responsive_layout_test.dart` covers narrow mobile widths for the shared quick-entry sections and one long-email Mine profile layout.

Known gaps:

- There is no global app breakpoint taxonomy yet. Width decisions are currently local and ad hoc.
- `MainPage` is still mobile-first: it always uses a bottom navigation bar. There is no tablet/desktop `NavigationRail`, side navigation, or two-pane shell yet.
- `AppCanvasPageScaffold` is a visual scaffold, not an adaptive layout scaffold. It does not provide max-width content lanes, side panels, master-detail slots, or desktop content density rules.
- The app currently changes spacing, wrapping, and card sizing, but it does not yet change feature content between phone, tablet, desktop, and web.
- Responsive tests currently focus on narrow mobile overflow; tablet, desktop, and web-width regression tests are still missing.

Next responsive foundation tasks before product-facing responsive work:

1. Add `lib/shared/layout/` with named breakpoints and window classes, for example compact, medium, expanded, and web-expanded.
2. Add a shared adaptive shell that can choose bottom navigation on compact widths and rail/sidebar navigation on wider widths.
3. Add page content constraints such as max readable width, centered content lanes, and optional side panels.
4. Convert one migrated feature first, preferably Home, to compact and expanded page variants as the reference pattern.
5. Expand widget tests to cover at least 393, 768, and 1280 logical-pixel widths.

Started on 2026-05-24:

- Added `lib/shared/layout/` with `AppWindowClass` and global breakpoints: compact `<600`, medium `600-839`, expanded `840-1199`, and web-expanded `>=1200`.
- Added `AppAdaptiveScaffold` as the first shared adaptive shell for compact bottom navigation versus wide navigation pane.
- Updated `MainPage` to keep the existing bottom tab bar on compact widths and switch to `NavigationRail` on medium and wider widths. Expanded and web-expanded widths use an extended rail/sidebar presentation.
- Added `test/adaptive_layout_test.dart` to lock the breakpoint mapping and compact/wide shell switching behavior.

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

## Phase 4: Backend Migration to NestJS + PostgreSQL

The backend migration should be a controlled architecture migration, not a product rewrite.

### 4.1 Migration strategy

Move toward a single NestJS backend with PostgreSQL as the primary store.

If parity verification requires it, a temporary parallel Nest runtime is acceptable during the cutover window, but it is not the desired steady state.

Recommended structure:

```text
backend/
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
- Replace MongoDB + MySQL data ownership with PostgreSQL-backed modules instead of reintroducing dual persistence in the new architecture.

### 4.2 Suggested Nest module mapping

- `auth`: login, register, refresh, user profile, verification code delivery.
- `medicines`: search, detail, AI detail, AI safety, scan recognition.
- `my-medicines`: user medicine collection.
- `reminders`: reminder plans and today reminders.
- `scan-records`: scan history create/list.
- `ai`: LangChain gateway, prompt builders, text cache.
- `db`: PostgreSQL access layer and optional Redis providers.
- `common`: response envelope, error mapping, auth guard, validation pipes.

### 4.3 Migration phases

1. Define the target PostgreSQL schema that replaces current MongoDB user data and MySQL medicine tables.
2. Scaffold the NestJS application entry and move shared config/env parsing into Nest config providers.
3. Add PostgreSQL data access, migration scripts, and seed/import tooling; wire Redis only for clearly justified short-lived cache flows.
4. Move the AI module first because it is already centralized and testable.
5. Move medicine public routes and decide whether medicine data lands fully in PostgreSQL or is refreshed into PostgreSQL from an external upstream source.
6. Move auth, verification-code delivery, and JWT guard.
7. Move user-scoped routes after Phase 2 auth rules are already tested.
8. Run Express and Nest parity tests before switching deployment, then retire MongoDB/MySQL runtime dependencies.

Acceptance:

- Flutter does not need route changes during the migration.
- Express tests have equivalent Nest tests before a route is switched.
- PostgreSQL becomes the primary persisted source for migrated modules.
- Redis remains optional and limited to cache/code scenarios rather than becoming a second primary database.
- Docker and deployment docs clearly state which backend entrypoint is active during the cutover window.

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
- Set the recommended structure-first execution order to `Settings -> Main shell -> Home -> Search -> Scan`, then frontend shared UI and remaining active page shells before backend work.
- Started the first structural slice by moving the Settings presentation code toward `lib/features/settings/` while keeping compatibility with existing imports.
- Completed the second structural slice by moving the main shell presentation and controller code into `lib/features/main_shell/`, splitting the old oversized `main.dart` into page, bottom-bar, and ornament support files while keeping legacy export wrappers.
- Completed the fifth structural slice by moving scan presentation code into `lib/features/scan/presentation/`, splitting the old scan page into page, image-flow support, labels, preview, sheet, result, and action files while keeping legacy export wrappers.
- Re-scoped `Phase 0` as Flutter project-base work only; backend auth splitting and NestJS/PostgreSQL implementation are deferred to later backend phases.
- Started the shared UI base slice by moving app surface, tinted status chip, responsive quick grid, quick entry style, and shared quick entry card primitives into `lib/shared/widgets/`, with old component paths kept as compatibility exports.
- Split the shared ornament definitions into `lib/shared/widgets/ornaments/`, separating models, banner layouts, section layouts, and layout sets while keeping `lib/components/app_ornaments.dart` as a compatibility export.
- Recorded the responsive readiness checkpoint: current responsive support is component-level and mobile-overflow focused, while global breakpoints, adaptive app shell, desktop/web content variants, and wider viewport tests still need to be added.
- Started the responsive foundation by adding shared layout breakpoints, `AppAdaptiveScaffold`, and a medium/expanded `NavigationRail` path for `MainPage` while preserving the compact bottom bar behavior.
- Completed the sixth structural slice (`Drug`): split `lib/components/drug.dart` (697→3 files) and `lib/pages/Drug/medicine_detail.dart` (763→4 files), moved data models into `lib/features/drug/presentation/models/`, and collapsed 7 old paths into compatibility re-exports while updating 7 cross-repo imports. All new files ≤600 lines; `flutter analyze` clean.
- Added `.flutter` and `.flutter_tool_state` to `.gitignore` as Flutter SDK local tool state.
- Completed the seventh structural slice (`Reminders`): split `lib/pages/Reminders/reminder_list.dart` (730→3 files: page + list widgets + card) and `reminder_edit.dart` (687→2 files: page + edit widgets), copied controllers, and collapsed 4 old paths into compatibility re-exports while updating 3 cross-repo imports. All new files ≤600 lines; `flutter analyze` clean with 1 pre-existing info lint.
- Completed the eighth structural slice (`Safety`): split `lib/pages/Safety/safety_assist.dart` (956→2 files: page + widgets), copied controller, collapsed 2 old paths into compatibility re-exports, updated 3 cross-repo imports. `flutter analyze` clean (1 pre-existing info).
- Completed the ninth structural slice (`Mine`): split `lib/components/mine.dart` (658→2 files: profile card 221 + page widgets 397), migrated `mine.dart`, `browse_history.dart`, and 2 controllers, collapsed 6 old paths, updated 4 cross-repo imports. `flutter analyze` clean.
- Completed the tenth structural slice (`Album`): split `lib/components/album.dart` (1075→4 files: page_widgets 181 + slivers 450 + card 224 + preview 210), migrated page and controller, collapsed 3 old paths, updated 2 cross-repo imports. `flutter analyze` clean.
- Completed the eleventh structural slice (`CheckIn`): migrated page and controller to `lib/features/checkin/presentation/`, collapsed 2 old paths, updated router import. `flutter analyze` clean.
- Normalized naming: renamed `DrugView`→`DrugPage`, `AlbumView`→`AlbumPage`, `MineView`→`MinePage` (route-level pages), layout widgets renamed to `XxxLayout`. Fixed `use_build_context_synchronously` info lint in reminder_edit_page.
- Completed the twelfth and thirteenth structural slices (`Login` + `Register`): migrated both pages and controllers to `lib/features/login/presentation/` and `lib/features/register/presentation/`, renamed `RegisterView`→`RegisterPage`, updated `login_controller` to reference `RegisterPage` via barrel, collapsed 4 old paths, updated router and test imports. `flutter analyze` clean; all 19 `flutter test` passing.

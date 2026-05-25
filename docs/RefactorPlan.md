# Luminous Optimization and Nest Migration Plan

Last updated: 2026-05-25

## Goal

Luminous is already functional, and the current checks pass. The next work should focus on turning it from a demo-friendly app into a durable product:

1. Remove demo behavior from real user flows.
2. Make user data ownership and auth boundaries explicit.
3. Replace weak medicine data foundations with a server-side knowledge platform.
4. Introduce Markdown as the standard long-text display path for medicine details and AI output.
5. Prepare the backend for a NestJS + PostgreSQL + Prisma + Redis + Passport migration without breaking the current Flutter app.

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
- `lib/assets/data.json` is only a tiny development fixture. It is not the future medicine knowledge source.
- New external knowledge sources exist outside Git: `D:\DrugDataBase\FullDrugDetail.xlsx` and `D:\DrugDataBase`.

Target backend end-state for this plan:

- Framework: NestJS.
- Primary data store: PostgreSQL.
- Data access and import tooling: Prisma, with raw SQL allowed for search ranking/import cases Prisma cannot express cleanly.
- Auth guards: Passport with JWT strategy.
- Redis: keep for verification codes, cooldowns, short-lived cache, and selected AI result cache.
- MongoDB and MySQL are migration sources to retire, not long-term dependencies to preserve.
- Medicine facts come from PostgreSQL-backed knowledge tables, not AI-generated text.

Detailed knowledge/data direction:

- `docs/knowledge-data-platform-plan.md` is the source of truth for the new xlsx + DrugBank data platform, Markdown strategy, and AI responsibility split.

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

### 0.3 Structural slice status

Completed on 2026-05-24:

1. `Settings`: split `settings.dart`, move the page stack into `lib/features/settings/`, and keep old imports as compatibility exports.
2. `Main shell`: split `MainPage`, controller, bottom bar, ornament support, and wide navigation rail into `lib/features/main_shell/presentation/`.
3. `Home`: separate page composition, controller, support data, and widgets under `lib/features/home/presentation/`; `HomePage` is the canonical feature entry.
4. `Search`: split page, controller, prompt/result slivers, cards, and tip widgets under `lib/features/search/presentation/`; `SearchPage` is the canonical feature entry.
5. `Scan`: split page orchestration, controller, image-flow support, labels, selected-image model, sheet, photo area, actions, and result section under `lib/features/scan/presentation/`.
6. `Shared UI base`: move cross-feature surfaces, auth UI primitives, soft banner primitives, status chips, quick-entry styles/cards, responsive quick-grid primitives, ornament layouts, and app canvas scaffolds into `lib/shared/widgets/`; split `AppSurface`, auth UI, soft banner, and ornament layout definitions into smaller shared files.
7. `Responsive shell base`: add `lib/shared/layout/`, global breakpoint/window-class definitions, `AppAdaptiveScaffold`, and compact bottom navigation versus wide rail/sidebar behavior for `MainPage`.
8. `Drug`: split drug list, medicine detail, controllers, presentation widgets, and presentation models under `lib/features/drug/presentation/`; route-level naming is now `DrugPage`.
9. `Reminders`: split list/edit pages, controllers, reminder card, list widgets, and edit widgets under `lib/features/reminders/presentation/`.
10. `Safety`: split safety assist page, controller, and widgets under `lib/features/safety/presentation/`.
11. `Mine`: split mine page, browse history page, controllers, profile card, and page widgets under `lib/features/mine/presentation/`; route-level naming is now `MinePage`.
12. `Album`: split album page, controller, preview, card, page widgets, and slivers under `lib/features/album/presentation/`; route-level naming is now `AlbumPage`.
13. `CheckIn`: move check-in page and controller under `lib/features/checkin/presentation/`.
14. `Login` and `Register`: move login/register pages and controllers under `lib/features/login/presentation/` and `lib/features/register/presentation/`; route-level naming is now `RegisterPage`.
15. `MedicinePicker`: move the cross-feature medicine picker page and controller under `lib/features/medicine_picker/presentation/`, and keep old `lib/pages/Picker/*` paths as compatibility exports.
16. `Legal` and `Profile settings`: move legal document pages under `lib/features/legal/presentation/`, move profile settings page/controller under `lib/features/settings/presentation/`, and keep old paths as compatibility exports.
17. `Legacy directory cleanup`: retire active `lib/components/`, `lib/pages/`, `lib/stores/`, and `lib/viewmodels/` usage; old compatibility and deprecated code now lives under `lib/deprecated/`.
18. `Root and constants cleanup`: move `RootAppWidget` out of `lib/routes/` into `lib/core/startup/`, split constants by responsibility, and keep `constants.dart` as a barrel export.

Remaining Phase 0 cleanup:

1. Continue the responsive base with shared content lanes, max-width constraints, optional side panels, and one feature-level compact/expanded reference implementation beyond Home.
2. Add the minimal integration/e2e smoke baseline before deeper generated-code migration work; see `0.6`.
3. Replace hand-written API/DTO JSON serialization with generated model code in a dedicated slice, preferably using `json_serializable` plus `build_runner` after model ownership has stabilized; see `0.6`.
4. Evaluate typed local persistence before expanding cache/offline tables; see the Drift notes in `0.6`.
5. Replace JSON/string-based object equality and ad hoc list/set equality with explicit `collection` equality helpers where practical.
6. Decide when to retire `lib/deprecated/` files from the repository entirely after one stable checkpoint confirms no rollback path is needed.

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

- The refactor has preserved useful responsive seams at the feature and widget level. Migrated pages now have feature-owned entry points such as `HomePage`, `SearchPage`, `MedicineScanPage`, `DrugPage`, `AlbumPage`, and `MinePage`, which makes it possible to add compact, medium, and expanded variants inside each feature later.
- `lib/shared/layout/` now defines the global breakpoint taxonomy through `AppWindowClass`: compact `<600`, medium `600-839`, expanded `840-1199`, and web-expanded `>=1200`.
- `AppAdaptiveScaffold` is the first shared adaptive shell. `MainPage` keeps the compact bottom tab bar on phone widths and switches to `NavigationRail` / extended rail on wider widths.
- `lib/shared/widgets/responsive_quick_grid.dart` already centralizes one compact breakpoint at `600dp`, text-scale-aware quick-entry metrics, and `ResponsiveQuickWrap`.
- Home, Drug, and Mine quick-entry sections already consume the shared responsive quick-grid primitives instead of hardcoding fixed card widths.
- Settings theme style selection already uses local `500dp` and `720dp` breakpoints to change column count.
- Several migrated feature pages still use `LayoutBuilder` or `Wrap` for local compact handling, including Album, Drug detail, Reminders, CheckIn, Safety, and Mine.
- `test/responsive_layout_test.dart` covers narrow mobile widths for the shared quick-entry sections and one long-email Mine profile layout.
- `test/adaptive_layout_test.dart` covers breakpoint mapping and compact/wide adaptive shell switching.

Known gaps:

- `AppCanvasPageScaffold` now has a canonical home under `lib/shared/widgets/`, but it is still a visual scaffold, not an adaptive layout scaffold. It does not provide max-width content lanes, side panels, master-detail slots, or desktop content density rules.
- The app currently changes spacing, wrapping, and card sizing, but it does not yet change feature content between phone, tablet, desktop, and web.
- Feature-level responsive tests still focus on narrow mobile overflow; tablet, desktop, and web-width feature regression tests are still missing.

Next responsive foundation tasks before product-facing responsive work:

1. Add page content constraints such as max readable width, centered content lanes, and optional side panels.
2. Convert one migrated feature first, preferably Home, to compact and expanded page variants as the reference pattern.
3. Expand widget tests to cover at least 393, 768, and 1280 logical-pixel widths.
4. Gradually replace local ad hoc width rules with `AppWindowClass` where doing so reduces duplication.

Started on 2026-05-24:

- Added `lib/shared/layout/` with `AppWindowClass` and global breakpoints: compact `<600`, medium `600-839`, expanded `840-1199`, and web-expanded `>=1200`.
- Added `AppAdaptiveScaffold` as the first shared adaptive shell for compact bottom navigation versus wide navigation pane.
- Updated `MainPage` to keep the existing bottom tab bar on compact widths and switch to `NavigationRail` on medium and wider widths. Expanded and web-expanded widths use an extended rail/sidebar presentation.
- Added `test/adaptive_layout_test.dart` to lock the breakpoint mapping and compact/wide shell switching behavior.

### 0.6 Type-safety and smoke-test backlog

Recorded on 2026-05-25. These are real Phase 0 follow-up issues, but they should stay as separate verified slices rather than being mixed into directory-structure cleanup.

Priority order:

1. Add a minimal e2e smoke baseline.
2. Introduce generated JSON model code for stable DTO/API result/shared models.
3. Replace fragile equality checks with `collection` helpers.
4. Evaluate Drift before adding more local cache/offline tables.

#### Minimal e2e smoke

Current issue:

- The repo has no `integration_test/` directory.
- `pubspec.yaml` does not declare the Flutter SDK `integration_test` package.

Package to add:

- `dev_dependencies`: `integration_test` from the Flutter SDK.

Initial files and flows:

- Add `integration_test/app_smoke_test.dart`.
- Cover app launch and basic auth/login/register/legal navigation.
- Cover one stable primary flow: medicine search or reminder list/edit/check-in. Prefer local/mockable flows first so the smoke test is not blocked by backend availability.

Acceptance:

- `flutter test integration_test/app_smoke_test.dart` can run on an available emulator, device, or desktop target.
- The smoke test stays small enough for release/checkpoint validation; it does not need to become a full per-commit gate.

#### Generated JSON models

Current issue:

- Large parts of the model layer still hand-write `fromJson`, `toJson`, and often `copyWith`.
- Known hotspots include auth, medicine, reminder, scan, safety, my-medicine, browse-history, album, search, and shared home/medicine models.
- The current repo has no `json_serializable`, `json_annotation`, `build_runner`, `freezed`, or `freezed_annotation` dependency.

Packages to add for the first slice:

- `dependencies`: `json_annotation`.
- `dev_dependencies`: `build_runner`, `json_serializable`.

Optional later packages:

- `dependencies`: `freezed_annotation`.
- `dev_dependencies`: `freezed`.
- Add Freezed only for complex immutable models that actually benefit from generated `copyWith`, equality, and sealed unions. Do not force every DTO into Freezed.

First migration targets:

- Stable API result/DTO models after their ownership is clear.
- Cross-feature shared models: `lib/shared/models/medicine.dart`, `lib/shared/models/home.dart`.
- Feature models with broad hand-written serialization: `lib/features/auth/presentation/models/auth.dart`, `lib/features/reminders/presentation/models/reminder.dart`, `lib/features/scan/presentation/models/scan.dart`, `lib/features/safety/presentation/models/safety.dart`, `lib/features/drug/presentation/models/my_medicine.dart`, `lib/features/mine/presentation/models/browse_history.dart`, `lib/features/album/presentation/models/album.dart`, and `lib/features/search/presentation/models/search.dart`.

Rules:

- Do not replace the whole repo in one pass.
- Start with stable DTO/shared model files and keep behavior-compatible generated output.
- Keep local database row mappers separate until the Drift decision is made.

Acceptance:

- Migrated DTO files use generated `*.g.dart` code instead of manual JSON field copying.
- `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze`, and focused model tests pass.

#### Local SQLite type safety

Current issue:

- `lib/core/local_storage/app_database.dart` manually creates tables, indexes, and upgrade behavior.
- Local repositories still use a lot of `Map<String, dynamic>` row mapping, especially `lib/features/drug/data/my_medicine_repository.dart`, `lib/features/reminders/data/reminder_local_store.dart`, and `lib/features/reminders/data/today_reminder_local_store.dart`.

Packages to evaluate:

- `dependencies`: `drift`, `drift_flutter`.
- `dev_dependencies`: `drift_dev`, `build_runner`.

Decision rule:

- Do not migrate SQLite immediately just to add a package.
- Evaluate Drift before adding more cache/offline tables, because it would give typed tables, DAOs, migrations, and compile-time query checks.
- Land Drift only after the minimal e2e smoke and the first JSON-generation slice are stable.

#### Collection equality

Current issue:

- `lib/features/mine/data/browse_history_store.dart` compares object state by serializing JSON.
- `lib/features/search/presentation/controllers/search_controller.dart` contains ad hoc list/set comparison logic.

Package to add:

- `dependencies`: `collection`.

Acceptance:

- Use `ListEquality`, `SetEquality`, or `DeepCollectionEquality` where the comparison is about value equality.
- Do not use `jsonEncode(toJson())` as an equality proxy unless the product explicitly needs canonical serialized payload comparison.

#### Deferred package decisions

- Keep `dio` and the current `DioRequest` wrapper during Phase 0. `retrofit` and `retrofit_generator` can wait until the NestJS/PostgreSQL API shape is stable and endpoint count justifies generated clients.
- Do not continue growing AI text segmentation with complex regular expressions. The new knowledge-platform direction is backend structured sections plus Markdown output; add a renderer such as `flutter_markdown` in the dedicated Markdown UI slice.
- Do not add a large form library for auth validation. Keep phone, code, and password rules centralized in `AuthValidators`; email validation can use a small validator package later if the benefit becomes clear.

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

## Phase 3: Medicine Knowledge Platform and Markdown Detail

Problem:

- The old medicine foundation is too weak for the Personal Health Copilot vision.
- The full xlsx and DrugBank datasets are far beyond what Flutter should bundle or scan locally.
- `LocalMedicineStore` still loads and decodes the tiny JSON fixture, which is acceptable only for development fallback.
- Long medicine text and AI text are still displayed through custom UI/string segmentation instead of Markdown.

Preferred direction:

- Build a backend PostgreSQL medicine knowledge platform from the external xlsx and DrugBank sources.
- Keep Flutter clients thin: they query backend APIs and render structured sections/Markdown.
- Use local Flutter storage only for user-owned offline data or small cached snapshots, not the full knowledge base.

Tasks:

- Follow the data architecture in `docs/knowledge-data-platform-plan.md`.
- Add PostgreSQL/Prisma staging tables and import scripts for `D:\DrugDataBase\FullDrugDetail.xlsx`.
- Stream DrugBank XML/CSV into backend staging tables; never load the full XML into memory.
- Normalize medicine product, instruction section, identifier, category, search document, and DrugBank enrichment tables.
- Keep the existing medicine search/detail API compatible while adding richer structured sections and `detailMarkdown`.
- Add Flutter Markdown rendering for medicine detail and AI/copilot outputs.
- Replace AI-generated generic medicine detail with database-backed detail and optional grounded explanation.

Acceptance:

- Full source datasets remain outside Git and outside Flutter assets.
- xlsx source row count, imported staging row count, and normalized target count are reported and explainable.
- Medicine search supports product name, brand, approval number, manufacturer, barcode, and national drug code.
- Medicine detail returns structured sections and Markdown without breaking old Flutter clients during the transition.
- AI outputs and medicine detail can render Markdown safely in Flutter.

## Phase 4: Backend Migration to NestJS + PostgreSQL + Prisma + Redis + Passport

The backend migration should be a controlled architecture migration, not a product rewrite.

Detailed execution steps are tracked in `docs/backend-nestjs-pgsql-migration-plan.md`.

### 4.1 Migration strategy

Move toward a single NestJS backend with PostgreSQL as the primary store and Prisma as the schema/import/migration tool.

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
    knowledge/
    copilot/
    reports/
    safety/
    db/
    prisma/
```

Key compatibility rules:

- Preserve the current route paths under `/api/*`.
- Preserve the response envelope `{ code, msg, result }`.
- Preserve existing JWT token semantics until Flutter no longer depends on them.
- Reuse the current AI helper contracts where possible.
- Use Passport JWT strategy for protected routes.
- Replace MongoDB + MySQL data ownership with PostgreSQL-backed modules instead of reintroducing dual persistence in the new architecture.
- Keep Redis limited to short-lived state and cache.
- Keep Prisma as the primary data access layer; use raw SQL for Chinese search ranking and import-heavy paths when needed.

### 4.2 Suggested Nest module mapping

- `auth`: login, register, refresh, user profile, verification code delivery, Passport strategies/guards.
- `medicines`: search, database-backed detail, Markdown sections, scan recognition.
- `knowledge`: source metadata, xlsx/DrugBank import status, source mapping, enrichment lookup.
- `my-medicines`: user medicine collection.
- `reminders`: reminder plans and today reminders.
- `scan-records`: scan history create/list.
- `ai`: LangChain gateway, prompt builders, parser, text cache.
- `copilot`: grounded explanation, medicine safety review, report summaries, doctor/family share summaries.
- `reports`: report upload/OCR/structured metrics, later health-report interpretation.
- `safety`: deterministic and AI-assisted interaction/risk checks.
- `db`: PostgreSQL access layer and optional Redis providers.
- `common`: response envelope, error mapping, auth guard, validation pipes.

### 4.3 Migration phases

1. Define the target PostgreSQL schema for user data, medicine knowledge, DrugBank enrichment, and source metadata.
2. Scaffold the NestJS application entry and move shared config/env parsing into Nest config providers.
3. Add Prisma, PostgreSQL migrations, and import script scaffolding; wire Redis only for clearly justified short-lived flows.
4. Freeze current Express API contracts and add parity tests.
5. Move public medicine search/detail first, backed by PostgreSQL knowledge tables and Markdown sections.
6. Move AI into grounded copilot services instead of preserving generic AI detail as a long-term feature.
7. Move auth, verification-code delivery, Passport JWT guard, and users.
8. Move user-scoped routes after Phase 2 auth rules are already tested.
9. Run Express and Nest parity tests before switching deployment, then retire MongoDB/MySQL runtime dependencies.

Acceptance:

- Flutter does not need route changes during the migration.
- Express tests have equivalent Nest tests before a route is switched.
- PostgreSQL becomes the primary persisted source for migrated modules.
- Prisma migrations and import scripts can rebuild the knowledge tables from external sources.
- Redis remains optional and limited to cache/code scenarios rather than becoming a second primary database.
- Docker and deployment docs clearly state which backend entrypoint is active during the cutover window.

## Phase 5: Testing and Performance Baseline

Tasks:

- Extend the Phase 0 minimal `integration_test` smoke into fuller flows for login, scan-to-detail, and reminder-create-to-checkin.
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
- Updated the Phase 0 status checkpoint: most active presentation modules now have canonical homes under `lib/features/`, shared UI and adaptive shell primitives live under `lib/shared/`, and remaining cleanup is limited to smaller page islands, data/model ownership decisions, compatibility wrapper retirement, and responsive content-lane work.
- Moved `AppCanvas` and `AppCanvasPageScaffold` into `lib/shared/widgets/app_canvas.dart`, kept `lib/components/app_canvas.dart` as a compatibility export, and updated active imports to the shared path.
- Split `SoftBanner` into `lib/shared/widgets/soft_banner/` with separate palette, card, and ornament files, kept `lib/components/soft_banner.dart` as a compatibility export, and updated active imports to the shared path.
- Split authentication UI primitives into `lib/shared/widgets/auth/` with separate scaffold, card, method switcher, legal, and model files, kept `lib/components/auth.dart` as a compatibility export, and updated active login/register imports to the shared path.

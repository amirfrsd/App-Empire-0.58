# App Empire Task List

## Phase 1 — Foundation and risk-first proof

### Task 1: Scaffold the iPhone project

- [x] Create the Xcode 27 SwiftUI iPhone project, test targets, source folders, `.gitignore`, and scheme.
- Acceptance: The app launches into a placeholder portrait shell; unit and UI test targets exist; the project builds on an available iPhone simulator.
- Verify: `xcodebuild build -scheme AppEmpire -destination 'platform=iOS Simulator,name=iPhone 17'`.
- Dependencies: None.
- Files likely touched: `AppEmpire.xcodeproj`, `AppEmpire/App/AppEmpireApp.swift`, `AppEmpireTests/`, `AppEmpireUITests/`, `.gitignore`.
- Estimated scope: Medium.

### Task 2: Import and validate reference configuration

- [x] Add versioned economy/product JSON and Codable models for the reference configuration.
- Acceptance: Economy config parses; exactly 120 unique products load; categories/tiers and positive costs validate; UI code does not contain balance constants.
- Verify: Focused config unit tests plus a catalog count assertion.
- Dependencies: Task 1.
- Files likely touched: `AppEmpire/Resources/`, `AppEmpire/Economy/ConfigModels.swift`, `AppEmpireTests/ConfigLoadingTests.swift`.
- Estimated scope: Medium.

### Task 3: Implement the deterministic economy engine

- [x] Build pure state/action types and the first red-green tests for hourly rates, aggregate portfolio income, active tap rewards, elapsed income, rounding, caps, invalid actions, and deterministic replay.
- Acceptance: Two `$8/hour` apps expose `$16/hour`; configured active tap target produces the documented initial `$0.16` parity value; identical inputs produce identical state; balances never go negative.
- Verify: Focused economy test suite and property-style boundary tests.
- Dependencies: Task 2.
- Files likely touched: `AppEmpire/Economy/Engine.swift`, `AppEmpire/Economy/Models.swift`, `AppEmpireTests/EconomyEngineTests.swift`.
- Estimated scope: Medium.

### Checkpoint A — Foundation

- [ ] Config, engine tests, deterministic replay, and build all pass.
- [ ] Commit foundation increments with descriptive atomic messages.

## Phase 2 — Offline vertical slice

### Task 4: Add versioned local persistence

- [ ] Persist player state, app state, schema/config versions, last simulation time, action journal, and rolling backup using a transactional local store.
- Acceptance: Saves survive relaunch; migration failure does not destroy the previous snapshot; duplicate idempotency keys do not duplicate rewards.
- Verify: Persistence integration tests including migration and crash-recovery fixtures.
- Dependencies: Task 3.
- Files likely touched: `AppEmpire/Persistence/PlayerStore.swift`, `AppEmpire/Persistence/Models.swift`, `AppEmpireTests/PersistenceTests.swift`.
- Estimated scope: Medium.

### Task 5: Build the visual system and portrait tab shell

- [ ] Implement palette tokens, typography, materials/fallback surfaces, accessible controls, and Home/Products/Market/Season/Profile navigation.
- Acceptance: Portrait layout matches approved colors; tab bar is glassmorphic with a reduced-transparency fallback; all five destinations exist; labels and contrast are testable.
- Verify: Build plus UI snapshot/manual simulator check with Dynamic Type and reduced motion/transparency.
- Dependencies: Task 1.
- Files likely touched: `AppEmpire/DesignSystem/`, `AppEmpire/App/RootTabView.swift`, `AppEmpireUITests/NavigationTests.swift`.
- Estimated scope: Medium.

### Task 6: Ship the tutorial-to-Tap-to-Earn flow

- [ ] Implement starter app tutorial, Home balances/rates, global Tap to Earn, build/launch state, upgrade action, elapsed income, offline catch-up summary, and persistence wiring.
- Acceptance: Fresh install completes tutorial offline; the player sees per-app hourly income and aggregate rate; Tap to Earn awards aggregate value; relaunch and capped offline claim preserve state.
- Verify: Unit tests for action outcomes plus UI smoke test from fresh install through relaunch.
- Dependencies: Tasks 4 and 5.
- Files likely touched: `AppEmpire/Portfolio/PortfolioViewModel.swift`, `AppEmpire/Portfolio/HomeView.swift`, `AppEmpire/Portfolio/ProductsView.swift`, `AppEmpire/App/TutorialView.swift`, `AppEmpireUITests/CoreLoopTests.swift`.
- Estimated scope: Large; split into tutorial and core-loop increments.

### Checkpoint B — Offline loop

- [ ] Fresh install, tutorial, Tap to Earn, relaunch, and capped offline income work without network access.
- [ ] All tests and simulator smoke flow pass before product-depth work.

## Phase 3 — Product depth and visual polish

### Task 7: Add catalog browsing and app lifecycle depth

- [ ] Load all 120 products into Products; implement draft/building/launched/paused/retired states, slot unlocks, category/tier presentation, and product detail actions.
- Acceptance: Every catalog item is selectable; lifecycle transitions validate costs/tokens atomically; retired products remain in history and produce no income.
- Verify: Catalog/lifecycle unit tests and UI coverage for representative tiers.
- Dependencies: Task 6.
- Files likely touched: `AppEmpire/Portfolio/CatalogView.swift`, `AppEmpire/Portfolio/ProductDetailView.swift`, `AppEmpire/Economy/ProductLifecycle.swift`, `AppEmpireTests/ProductLifecycleTests.swift`.
- Estimated scope: Medium.

### Task 8: Implement contextual Founder Mode analytics

- [ ] Add contextual drill-downs for income, customers, churn, quality, marketing, forecasts, and reinvestment decisions from Home and Products.
- Acceptance: Founder Mode is reachable from relevant cards, explains values, respects Dynamic Type, and never becomes a separate tab.
- Verify: UI navigation/accessibility tests and deterministic forecast tests.
- Dependencies: Task 7.
- Files likely touched: `AppEmpire/Portfolio/FounderInsightsView.swift`, `AppEmpire/Portfolio/FounderInsightsModel.swift`, `AppEmpireTests/ForecastTests.swift`.
- Estimated scope: Medium.

### Task 9: Add upgrades, marketing, retention, and economy telemetry hooks

- [ ] Implement data-driven quality/retention/marketing upgrades, customer acquisition/churn effects, progression/achievements, and privacy-minimized local event emission.
- Acceptance: Upgrade curves come from config; paid effects are not mixed into ranked metrics; telemetry excludes secrets/raw tokens; all mutations remain atomic.
- Verify: Engine boundary tests and telemetry payload tests.
- Dependencies: Tasks 3, 7, and 8.
- Files likely touched: `AppEmpire/Economy/Upgrades.swift`, `AppEmpire/Portfolio/UpgradeView.swift`, `AppEmpire/Telemetry/Event.swift`, `AppEmpireTests/UpgradeTests.swift`, `AppEmpireTests/TelemetryTests.swift`.
- Estimated scope: Large; split engine and UI increments.

### Checkpoint C — Product experience

- [ ] 120 products load; Founder Mode works contextually; approved palette, portrait layout, accessibility, and five-tab shell pass review.

## Phase 4 — Online account and commerce

### Task 10: Define account and cloud-save contracts

- [ ] Adapt reference OpenAPI/SQL models for anonymous identity, refresh rotation, signed config, revisioned saves, conflicts, and audit request IDs.
- Acceptance: Client contracts tolerate retries/unknown fields; revision conflicts are explicit; no save overwrites a newer revision.
- Verify: Contract fixtures and client decoding tests.
- Dependencies: Tasks 4 and 6.
- Files likely touched: `backend/openapi.yaml`, `backend/database.sql`, `AppEmpire/Networking/APIModels.swift`, `AppEmpire/Networking/SaveSyncClient.swift`, `AppEmpireTests/SyncContractTests.swift`.
- Estimated scope: Large; split contract and client increments.

### Task 11: Implement account, sync, and conflict recovery

- [ ] Add anonymous sign-in, token/session storage, upload/download, revision merge/conflict UI, and offline retry queue.
- Acceptance: Anonymous player can sync; transient failures do not block local play; a conflict is visible and recoverable; tokens are not logged.
- Verify: Fake-server integration tests and UI conflict flow.
- Dependencies: Task 10.
- Files likely touched: `AppEmpire/Networking/AuthClient.swift`, `AppEmpire/Networking/SyncCoordinator.swift`, `AppEmpire/Profile/ProfileView.swift`, `AppEmpire/Profile/ConflictResolutionView.swift`, `AppEmpireTests/SyncIntegrationTests.swift`.
- Estimated scope: Large; split auth and save-sync increments.

### Task 12: Implement StoreKit commerce and durable grants

- [ ] Add product loading, purchase intent, StoreKit 2 transaction handling, server verification boundary, restoration, grant ledger, refunds, and revocations.
- Acceptance: Unverified client callbacks never grant currency; verified transaction IDs grant exactly once; restoration and revocation are represented in local state.
- Verify: StoreKit configuration tests, fake verification integration tests, and purchase UI test.
- Dependencies: Tasks 3 and 11.
- Files likely touched: `AppEmpire/Commerce/StoreService.swift`, `AppEmpire/Commerce/GrantCoordinator.swift`, `AppEmpire/Commerce/StoreView.swift`, `backend/purchases/`, `AppEmpireTests/CommerceTests.swift`.
- Estimated scope: Large; split client, contract, and grant increments.

### Checkpoint D — Online services

- [ ] Account/sync, conflict recovery, StoreKit verification boundary, exactly-once grants, restoration, and revocations pass tests.

## Phase 5 — Seasons, market, and competition

### Task 13: Implement minimal Market experience

- [ ] Add Market tab with category discovery, opportunities, purchase/build entry points, loading/error/offline states, and extension points for future content.
- Acceptance: Market is usable with local seed data offline and has a defined online loading boundary; no placeholder product rows are invented.
- Verify: Market model/UI tests and offline simulator check.
- Dependencies: Tasks 7 and 11.
- Files likely touched: `AppEmpire/Market/MarketView.swift`, `AppEmpire/Market/MarketModel.swift`, `AppEmpire/Portfolio/CatalogView.swift`, `AppEmpireUITests/MarketTests.swift`.
- Estimated scope: Medium.

### Task 14: Implement season scoring and checkpoint submission

- [ ] Add season lifecycle, versioned score calculation, verified checkpoint queue, cutoff handling, and exclusion of purchased currency/paid convenience effects.
- Acceptance: Closed seasons reject submissions; identical score inputs tie deterministically; paid effects cannot change ranked score; checkpoints are idempotent.
- Verify: Season engine and fake-server integration tests.
- Dependencies: Tasks 3, 11, and 12.
- Files likely touched: `AppEmpire/Season/SeasonModels.swift`, `AppEmpire/Season/ScoreEngine.swift`, `AppEmpire/Networking/SeasonClient.swift`, `AppEmpireTests/SeasonScoringTests.swift`, `backend/seasons/`.
- Estimated scope: Large; split score engine and networking increments.

### Task 15: Implement leaderboard, rewards, and Season UI

- [ ] Add leaderboard paging, deterministic tie-break display, season status, reward claim, and idempotent settlement UI.
- Acceptance: Leaderboard pages are stable; rewards claim once; season cutoff and claim grace states are visible; offline errors are non-blocking.
- Verify: UI tests plus reward-grant integration tests.
- Dependencies: Task 14.
- Files likely touched: `AppEmpire/Season/SeasonView.swift`, `AppEmpire/Season/LeaderboardView.swift`, `AppEmpire/Season/RewardClaimView.swift`, `AppEmpireTests/RewardTests.swift`, `AppEmpireUITests/SeasonTests.swift`.
- Estimated scope: Large; split UI and settlement increments.

### Checkpoint E — Competition

- [ ] Season cutoff, score rules, leaderboard paging, tie-breaking, reward settlement, and quarantine behavior pass tests.

## Phase 6 — Backend hardening and release

### Task 16: Implement backend persistence, integrity, audit, and telemetry boundaries

- [ ] Bring the adapted PostgreSQL schema and OpenAPI endpoints to a minimal runnable service with authorization, rate limits, request IDs, structured audit events, payload validation, and abuse quarantine.
- Acceptance: Server rejects invalid/replayed actions; financial/competition records are append-safe; sensitive data is not logged; API errors use the stable envelope.
- Verify: Backend unit/integration tests, schema migration test, and contract tests against the client fixtures.
- Dependencies: Tasks 10, 12, and 14.
- Files likely touched: `backend/`, `backend/database.sql`, `backend/openapi.yaml`, `docs/backend-runbook.md`, `AppEmpireTests/BackendContractTests.swift`.
- Estimated scope: Large; split by endpoint family.

### Task 17: Accessibility, resilience, and release QA

- [ ] Validate Dynamic Type, VoiceOver, reduced motion/transparency, contrast, network loss, migration failure, purchase restoration, and simulator/device performance.
- Acceptance: Critical flows remain usable under accessibility settings and offline failure; no critical crashes or data-loss paths remain.
- Verify: Full `xcodebuild test`, UI tests, simulator smoke run, accessibility audit, and manual checklist.
- Dependencies: Tasks 6, 8, 11, 12, and 15.
- Files likely touched: `AppEmpireUITests/AccessibilityTests.swift`, `AppEmpireUITests/ResilienceTests.swift`, `docs/release-checklist.md`, `docs/rollback-plan.md`.
- Estimated scope: Medium.

### Checkpoint F — Release candidate

- [ ] All acceptance criteria in `SPEC.md` pass.
- [ ] Full test/build suite is green on the available iPhone simulator.
- [ ] Migration, security, accessibility, monetization, and competition reviews are recorded.
- [ ] Working tree is clean and release notes are ready.

# App Empire — Product and Engineering Specification

## Objective

Build a new iPhone-only, portrait SwiftUI tap-to-earn idle tycoon. The player builds, launches, markets, operates, and grows a portfolio of apps. Each app generates passive income over time and contributes to a global active Tap to Earn action. The release must include working versions of the full system surface from the reference package: local gameplay, persistence, accounts, cloud sync, StoreKit monetization, seasons, leaderboards, rewards, and backend integrity/security.

The Desktop reference package is authoritative for the initial product vocabulary, economy concepts, 120 seeded products, API concerns, database concerns, security rules, and acceptance themes. Its static values remain tunable launch hypotheses, not immutable balance promises.

## Product experience

- Portrait-only iPhone layout with one-handed, tap-forward interactions.
- Five-tab structure from day one: Home, Products, Market, Season, Profile.
- Home is the primary action surface: balances, portfolio health, aggregate hourly income, Tap to Earn, next best action, and offline earnings.
- Products manages app selection, building, launch, upgrades, marketing, and lifecycle.
- Founder Mode is contextual inside Home and Products. Tapping income, customers, churn, marketing, upgrades, or forecasts opens deeper analytics; it is not a separate tab.
- Market and Season must exist as architectural modules from the first release, even if their initial content is intentionally small.
- The experience should be simple at the surface and strategically deep underneath.

## Economy contract

Each active app exposes an hourly income rate. Example: a level-1 app may generate `$2/hour`; a level-4 app may generate `$8/hour`. Four level-4 apps therefore expose `$32/hour` aggregate passive income.

Passive income is accrued by elapsed time and is subject to the configured offline catch-up cap. Active Tap to Earn is a separate action with no tap-count limit. Each tap awards an aggregate amount derived from the active portfolio's income rates and the documented active-tap balance model. The initial balancing target is that two apps at `$8/hour` each produce `$16/hour` passive income and approximately `$0.16` per tap at a 100-taps/hour parity target. This is configuration, not UI hard-coding.

All currency uses integer minor units in the engine. UI formatting may display friendly dollar values. Actions are atomic, deterministic, replayable from `(state, action, seed, elapsed_seconds)`, and idempotent where they cross a persistence or server boundary. Balances may never become negative.

## Reference-derived systems

- Starting state, AI Tokens, Gems, product slots, upgrade curves, catalog tiers, and 120 product seeds originate from `config/economy.json` and `config/products.json` in the reference folder.
- App lifecycle supports draft, building, launched, paused, and retired.
- Offline catch-up uses the same deterministic engine as foreground simulation and is capped with a transparent claim summary.
- Accounts/cloud save use revisioned state and visible conflict recovery; no newer save is silently discarded.
- StoreKit 2 purchases use server verification, durable idempotent grants, and compensating entries for revocations/refunds.
- Seasons use immutable time windows, versioned rules, verified checkpoints, deterministic tie-breakers, and idempotent rewards.
- Client input is never trusted for premium currency, purchases, scores, timestamps, or leaderboard results.

## UI/UX design system

| Token | Value |
|---|---|
| Background | `#053427` |
| Surface | `#094934` |
| Raised surface | `#0E5B41` |
| Lime accent / primary CTA | `#B5F649` |
| Ink / button text | `#001D13` |
| Main text | `#E8FAE3` |

Use layered green surfaces, lime action emphasis, readable hierarchy, restrained glass effects, and the latest iOS-style translucent tab-bar language available to the deployment target. Use Dynamic Type, VoiceOver labels, sufficient contrast, reduced motion, non-color-only status indicators, localized number formatting, and useful offline/error states.

## Tech stack and structure

- Client: Swift, SwiftUI, SwiftData or an equivalent transactional local store, StoreKit 2, URLSession/concurrency.
- Backend: API contract adapted from `backend/openapi.yaml`, PostgreSQL schema adapted from `backend/database.sql`, server-side verification and audit logging.
- Configuration: versioned economy and product JSON, loaded as data rather than duplicated in UI code.
- Proposed structure:

```text
App Empire/
├── AppEmpire.xcodeproj
├── AppEmpire/
│   ├── App/
│   ├── DesignSystem/
│   ├── Economy/
│   ├── Persistence/
│   ├── Portfolio/
│   ├── Market/
│   ├── Season/
│   ├── Profile/
│   ├── Commerce/
│   └── Networking/
├── AppEmpireTests/
├── AppEmpireUITests/
├── backend/
├── config/
├── docs/
└── tasks/
```

## Commands

The exact Xcode scheme and backend commands will be recorded after project scaffolding. The minimum required gates are:

```text
xcodebuild test -scheme AppEmpire -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild build -scheme AppEmpire -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Testing strategy

- Unit tests first for income formulas, tap rewards, elapsed time, caps, rounding, progression, migrations, idempotency, invalid actions, and deterministic replay.
- Integration tests for local persistence, cloud conflict resolution, StoreKit verification/grants, season submission, and backend boundaries.
- UI tests for first launch/tutorial, app creation, Tap to Earn, contextual Founder Mode, offline catch-up, tab navigation, and purchase restoration.
- Golden/replay tests ensure identical inputs produce identical state across versions.
- Acceptance tests must cover the reference package's stated gates: fresh offline tutorial, persistence after relaunch, capped catch-up, catalog loading, exactly-once grants, paid effects excluded from ranked score, usable offline play, and recoverable cloud conflict.

## Boundaries

- Always: keep economy values data-driven; use integer currency units; preserve migrations and idempotency; test behavior before implementation; maintain accessibility; keep client/server trust boundaries explicit.
- Ask first: changing the confirmed product direction, removing a major v1 system, adding paid behavior that affects competitive scoring, changing data migrations, or adding external services/dependencies.
- Never: trust client-reported purchases or scores; use floating point for currency; silently discard cloud progress; ship placeholder catalog rows; hard-code economy constants into UI; commit secrets.

## Success criteria

1. A fresh install can complete the tutorial and launch a starter app offline.
2. Active apps show hourly rates, aggregate portfolio income, and a global Tap to Earn action.
3. Tap payouts and passive/offline income are deterministic, persisted, capped, and covered by tests.
4. A player can inspect contextual Founder Mode details from Home and Products.
5. Accounts, cloud saves, StoreKit verification, seasons, leaderboards, and rewards work end-to-end in minimal v1 form.
6. Competitive score excludes purchased currency and paid convenience effects.
7. The app remains usable without network access and surfaces recoverable errors/conflicts.
8. The UI matches the approved palette and portrait iPhone glassmorphism direction with accessibility support.

## Reference files

The implementation must consult all files in `/Users/amirfarsaad/Desktop/app-empire-2.0`: `README.md`, `SPEC.md`, `VERIFICATION.md`, `backend/database.sql`, `backend/openapi.yaml`, `config/economy.json`, `config/products.json`, and `.DS_Store` only as a directory artifact (not as product input).

## Open questions

- Final app display name and bundle identifier.
- Minimum iOS deployment target.
- Exact active-tap reward curve and anti-automation policy for unlimited tapping.
- Backend hosting/runtime choice.
- Initial StoreKit product IDs and season content breadth.

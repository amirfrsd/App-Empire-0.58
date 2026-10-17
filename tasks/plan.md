# Implementation Plan: App Empire iPhone v1

## Overview

Build App Empire as a portrait-only SwiftUI iPhone app plus the minimal backend required for accounts, cloud saves, verified commerce, seasons, leaderboards, rewards, telemetry, and integrity checks. Work proceeds in vertical slices from deterministic economy through the user-facing portfolio loop, then adds the online systems without weakening offline play.

Reference inputs are the complete package at `/Users/amirfarsaad/Desktop/app-empire-2.0`. The new project keeps its rules data-driven and adapts the reference contracts rather than copying the package as implementation.

## Architecture decisions

1. **Pure economy core:** income, tapping, elapsed time, upgrades, progression, and validation live in UI-independent Swift types with no clock, network, or persistence dependency.
2. **Integer currency:** the engine stores cents and whole gems/tokens as integers. Display formatting is the only layer that adds currency symbols or localized decimals.
3. **Tap-to-earn model:** passive hourly income is calculated per app; active taps award an aggregate portfolio amount from a configurable parity target. There is no tap-count limit, but the curve remains data-driven so unlimited tapping can be balanced and abuse signals can be added later.
4. **Offline-first state:** local state is authoritative for playable progress. Every mutation is journaled/idempotent; cloud sync reconciles revisions and exposes conflicts instead of overwriting progress.
5. **Contextual Founder Mode:** deep analytics are presented from Home and Products detail flows, not as a sixth tab.
6. **Contract-first online systems:** the reference OpenAPI and SQL contracts are adapted before implementing online features. Client grants and competitive scores are never trusted without server verification.
7. **Incremental delivery:** every task leaves a buildable app and has a focused verification command/manual check. Each completed increment is committed separately.

## Dependency graph

```text
reference config + project scaffold
        │
        ├── economy engine ── local persistence ── portfolio UI ── tutorial loop
        │                                            │
        │                                            ├── Founder Mode
        │                                            └── Market shell
        │
        └── design system ── tab shell ──────────────┘

portfolio + persistence ── account/sync contract ── cloud save
economy + account/sync ── commerce verification/grants
economy + account/sync ── seasons/leaderboards/rewards
all online contracts ── backend integrity, audit, telemetry, hardening
```

## Delivery phases

### Phase 1 — Foundation and risk-first proof

Scaffold the Xcode project, import the reference JSON as versioned data, and prove the hardest balance/integrity assumptions in unit tests before building screens.

### Phase 2 — Offline vertical slice

Ship the first complete playable path: tutorial → build starter app → launch → see hourly income → Tap to Earn → upgrade → persist → relaunch → claim capped offline income.

### Phase 3 — Product depth and visual polish

Add the full seeded catalog, product lifecycle, marketing/retention/quality upgrades, contextual Founder Mode, and the approved green/lime glassmorphism design system.

### Phase 4 — Online account and commerce

Add anonymous/account identity, revisioned cloud saves, conflict recovery, StoreKit 2 product loading, server verification, durable grants, restoration, refunds, and revocations.

### Phase 5 — Seasons, market, and competition

Add a minimal but end-to-end Market, season lifecycle, score rules, verified checkpoint submission, leaderboard paging, deterministic tie-breaking, rewards, and anti-cheat quarantine.

### Phase 6 — Release hardening

Run migration rehearsals, accessibility and device checks, offline/network failure tests, load/security review, telemetry validation, localization readiness, App Store compliance checks, and staged-release/rollback preparation.

## Verification checkpoints

- **Checkpoint A — Foundation:** config loads; economy tests are green; replay is deterministic; no negative balances.
- **Checkpoint B — Offline loop:** tutorial and Tap to Earn work on a fresh install; state survives relaunch; offline cap is visible and enforced.
- **Checkpoint C — Product experience:** all 120 products load; UI matches tokens; Founder Mode and five-tab navigation are usable and accessible.
- **Checkpoint D — Online services:** account/sync and purchase grants are idempotent; conflicts and revocations are recoverable.
- **Checkpoint E — Competition:** season cutoff, score exclusion rules, tie-breaking, leaderboard pages, and reward settlement are verified.
- **Checkpoint F — Release:** full test suite, simulator smoke flow, security checks, migration rehearsal, and clean working tree.

## Risks and mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Unlimited tapping overwhelms passive balance | High | Keep the tap reward curve configurable, test parity targets, add telemetry/rate signals, and exclude paid boosts from ranked score. |
| iOS 27 glass effects vary by device/SDK | Medium | Use native materials with a fallback tokenized surface style; verify on the available iPhone simulator and reduced-transparency settings. |
| Cloud conflicts silently lose progress | High | Revision checks, action journal, rolling local backup, explicit conflict UI, and integration tests for both branches. |
| StoreKit or server verification unavailable in local development | High | Build against protocol-backed fakes and StoreKit test configuration; keep production grant path server-authoritative. |
| Backend scope expands beyond the client milestone | High | Define contracts first, deliver minimal end-to-end endpoints, and defer content breadth—not system correctness. |
| Reference balance values are unproven | Medium | Preserve them as versioned proposals and add telemetry/config versioning before tuning. |

## Open decisions to resolve during implementation

- Final display name, bundle identifier, and minimum deployment target.
- Backend runtime/hosting choice after local toolchain inspection.
- Exact tap reward function and automation signal thresholds.
- Initial StoreKit product IDs, season duration/content, and privacy-policy copy.

## Definition of done

The project is complete only when all success criteria in `SPEC.md` are met, the six checkpoints pass, tests cover the listed economy/persistence/online boundaries, the app is usable offline, and the repository has no uncommitted changes or committed secrets.

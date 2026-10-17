# Spec: Economy Engine

## Objective

Implement the UI-independent deterministic rules engine for App Empire. It must calculate each app's hourly passive income, aggregate portfolio income, active unlimited Tap to Earn rewards, elapsed/offline income, upgrades, and progression while preserving integer currency, atomic actions, replayability, and non-negative balances.

This module is the foundation for `portfolio-experience`, `local-persistence`, `commerce`, and `competition-integrity` in `CAPABILITY-MAP.md`. It uses the imported reference configuration as data, while keeping balance values tunable and versioned.

## Assumptions

1. Cash is stored as integer cents; AI Tokens and Gems are integer units.
2. Each active app has an hourly income rate derived from its product seed, level, quality, marketing, customers, retention, and configured modifiers.
3. Passive income accrues from elapsed time and is capped for offline catch-up by `offline.max_catchup_hours`.
4. Tap to Earn is a separate active action with no tap-count limit. The initial parity target is `$0.16` per tap for a portfolio of two apps earning `$8/hour` each, equivalent to 100 taps/hour of the `$16/hour` passive rate.
5. The engine receives time as an explicit input; it never reads the system clock, network, SwiftUI, or persistence directly.
6. Ranked score inputs must be separable from purchased currency and paid convenience effects.

## Functional requirements

### State

The engine state must represent:

- Cash cents, Gems, AI Tokens, founder progression, and unlocked product slots.
- Owned apps with product ID, lifecycle state, level, quality, marketing, retention, customers, and last simulation timestamp.
- Config version and a deterministic simulation/replay seed.
- Accumulated passive income eligible for display/claim and the last active-tap result context.

### Income

- An active app exposes an hourly income rate in integer cents after configured rounding.
- Aggregate portfolio rate is the sum of all eligible active app rates.
- An app that is paused or retired contributes no income.
- Passive elapsed income is proportional to elapsed seconds, bounded by the configured catch-up cap when the action is offline.
- Zero or negative elapsed time produces zero income and does not mutate balances.

### Tap to Earn

- A tap action evaluates all active apps together and awards one aggregate active-tap payout.
- There is no tap-count limit in the engine.
- The payout curve is configured, deterministic, and independent of real-time clock reads.
- The initial balance fixture must prove that two apps at `$8/hour` each produce `$0.16` per tap at the 100-taps/hour parity target.
- Taps cannot create negative balances, bypass costs, or directly alter ranked score inputs.

### Actions and integrity

- Build, launch, upgrade, market, tap, and elapsed-income actions validate preconditions before mutation.
- A failed action returns a typed rejection and leaves the state unchanged.
- Currency operations use integer arithmetic and configured rounding; floating point is not used for money.
- Actions can carry an idempotency key for persistence/server boundaries; repeating a successful keyed action must not duplicate its grant.
- Deterministic replay from the same state, action list, seed, and elapsed inputs produces the same state and summary.

## Public interface shape

Use small value types and explicit effects rather than UI-bound observable objects:

```swift
struct EconomyEngine {
    let config: EconomyConfig

    func hourlyRate(for app: OwnedApp) -> Int64
    func portfolioHourlyRate(in state: PlayerState) -> Int64
    func apply(_ action: EconomyAction, to state: PlayerState) throws -> EconomyResult
}
```

The concrete names may evolve if the behavior and boundary remain stable. UI view models must depend on this boundary, not duplicate formulas.

## Tech stack and commands

- Swift 6.0, Foundation, XCTest, iOS simulator SDK available through Xcode 27.
- No third-party dependency is required for the engine.

Focused test command:

```text
xcodebuild test -project AppEmpire.xcodeproj -scheme AppEmpire \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:AppEmpireTests/EconomyEngineTests CODE_SIGNING_ALLOWED=NO
```

Full verification commands:

```text
xcodebuild test -project AppEmpire.xcodeproj -scheme AppEmpire \
  -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
xcodebuild build -project AppEmpire.xcodeproj -scheme AppEmpire \
  -destination 'platform=iOS Simulator,name=iPhone 17' CODE_SIGNING_ALLOWED=NO
```

## Project structure

```text
AppEmpire/Economy/
├── Configuration.swift       # Reference JSON models and loader
├── Models.swift              # Player, app, action, and result values
├── Engine.swift              # Pure deterministic transitions and formulas
└── EconomyFormatting.swift   # Non-authoritative display helpers only

AppEmpireTests/
└── EconomyEngineTests.swift  # Formula, boundary, replay, and rejection tests
```

## Code style

- Prefer immutable structs, pure functions, typed errors, and explicit inputs.
- Name money fields with their storage unit (`cashCents`, `arpuCents`, `amountCents`).
- Keep formulas readable and testable; do not hide economy rules in view code.
- Use `Int64` for cash math and checked arithmetic where overflow is possible.

```swift
func portfolioHourlyRate(in state: PlayerState) -> Int64 {
    state.apps
        .filter { $0.lifecycle == .launched }
        .reduce(into: Int64.zero) { total, app in
            total += hourlyRate(for: app)
        }
}
```

## Testing strategy

- Unit tests cover two-app aggregate rate, per-app level progression, tap parity, zero elapsed time, offline cap, rounding, caps, invalid actions, upgrade costs, and non-negative balances.
- Property-style tests cover repeated actions, deterministic replay, and idempotency.
- Golden fixtures capture a known state/action sequence and expected result for future version migrations.
- No UI or persistence dependency is allowed in these tests.

## Boundaries

- Always: use reference configuration; use integer currency; make time explicit; preserve deterministic replay; validate before mutation; add a failing test before behavior changes.
- Ask first: change the tap parity target, add a new currency, change the definition of active income, or alter ranked-score exclusions.
- Never: read `Date.now`/system randomness inside the engine; use floating point for currency; trust UI-calculated totals; silently clamp invalid actions into successful ones; mutate state after a rejected action.

## Success criteria

1. Two `$8/hour` apps expose `$16/hour` aggregate passive income.
2. The configured initial parity fixture awards `$0.16` per active tap for that portfolio.
3. Four level-4 apps at `$8/hour` each expose `$32/hour`.
4. Passive and offline income obey elapsed time and the configured catch-up cap.
5. Rejected actions leave state unchanged and return typed errors.
6. Replaying identical inputs produces identical state and summaries.
7. No valid operation produces a negative balance or duplicate idempotent grant.
8. All focused and full Xcode tests pass without UI, network, or database access.

## Open questions

- Whether the active-tap parity target remains fixed at 100 taps/hour or becomes a curve by portfolio size.
- Whether fractional cent display is allowed for active taps or whether sub-cent rewards accumulate as an internal remainder.
- The exact customer/retention/marketing formula beyond the reference baseline.
- The maximum checked arithmetic policy when a very large portfolio approaches `Int64.max`.

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

## Reference economy contract

The engine must consume the complete reference economy configuration rather than re-implementing a small subset of constants in Swift. `config_version` is stored with every save and any balance change is a versioned migration.

### Currency and rounding

- Cash is `cash_cents` with a signed 64-bit maximum of `9_223_372_036_854_775_807`.
- Gems are whole units with a configured cap of `2_147_483_647`.
- AI Tokens are whole units with a configured maximum of 30.
- Currency operations use `half_up` rounding after each configured currency operation; UI formatting/localization is outside the engine.
- Overflow, negative results, and cap violations are rejected or safely clamped according to an explicit typed policy, never silently wrapped.

### Starting state and AI Tokens

- New players start with 90,000 cash cents, 12 AI Tokens, 0 Gems, founder level 1, and 1 product slot.
- AI Tokens regenerate one unit per 1,800 seconds up to the configured maximum.
- The daily free grant is 3; paid refill is disabled by the reference configuration.
- Product creation token costs are 3 for the first product, 4 for the second, 6 for the third, and a base cost of 7 for later products.
- Regeneration is elapsed-time based and deterministic; it must not require a wall-clock read inside the engine.

### Product simulation

Each launched app is simulated in discrete ticks of 60 seconds, with foreground and offline catch-up using the same transition function. The baseline reference equations are:

```text
demand = base_demand
       × category_multiplier
       × quality_multiplier
       × marketing_multiplier
       × season_modifier

new_customers = demand × acquisition_efficiency × elapsed_days
churned_customers = customers × churn_rate × elapsed_days
gross_revenue = active_customers × ARPU × elapsed_days
operating_cost = fixed_cost + customer_cost + campaign_spend
net_cash = gross_revenue − operating_cost
```

- Customers are capped at 1,000,000,000 per product.
- Reference simulation defaults are base ARPU 35 cents, base daily churn 0.035, quality multiplier range 0.5–2.0, marketing multiplier maximum 3.0, and season paid-boost multiplier 1.0.
- Product seed values override the base demand, ARPU, churn, build cost, AI-token cost, build time, category, tier, and complexity where present.
- Demand, acquisition, churn, revenue, and operating-cost steps are rounded using the configured policy and are never allowed to create negative customers or balances.
- All random outcomes use a documented seed and stable PRNG. System randomness is forbidden in replayable simulation.

### Offline catch-up

- Maximum catch-up is 8 hours.
- Claims below 60 seconds are not eligible.
- Claim cooldown is configured as 0 seconds in the reference economy.
- The result must state elapsed time considered, capped time, gross income, operating costs, net cash, token regeneration, and any expired effects.
- Claiming is atomic and idempotent; a crash cannot award the same offline interval twice.

### Progression and upgrades

- Launching awards 100 founder XP.
- Each 1,000 customers awards 10 founder XP.
- Level XP starts at 250 and grows by 1.18 per level.
- Product slots unlock at founder levels 1, 3, 6, 10, 15, and 21.
- Quality upgrades start at 12,000 cents, grow by 1.55, add 0.08 quality per level, and cap at level 10.
- Retention upgrades start at 16,000 cents, grow by 1.6, reduce churn by 0.015 per level, and cap at level 8.
- Marketing upgrades start at 9,000 cents, grow by 1.5, add 0.12 demand per level, and cap at level 10.
- Upgrade cost and effect calculations are data-driven and must be tested at level zero, maximum level, and the first level above maximum.

### Gems, store effects, and competitive separation

- Earnable Gems are 2 per daily challenge, 15 per weekly milestone, and up to 120 from the free season track.
- Store catalog data includes the five reference Gem packs, starter bundle, income convenience offer, season pass, VIP monthly offer, and Gem piggy bank.
- Store prices/contents are catalog data and are not granted by this local engine without a verified grant event.
- Paid currency and paid convenience effects must not affect ranked score. The reference ranked-score paid-boost multiplier is 1.0.

### Seasons and score inputs

- Seasons last 14 days; submissions are scheduled every 900 seconds; leaderboard pages contain 50 entries; reward claims remain available for 30 days after close.
- Ranked score weights are verified net cash growth 0.45, retention 0.30, and product quality 0.25.
- The engine exposes verified score inputs separately from casual portfolio value and excludes purchased Gems, paid Cash, VIP multipliers, and paid convenience boosts.

## Functional requirements

### State

The engine state must represent:

- Cash cents, Gems, AI Tokens, founder progression, and unlocked product slots.
- Owned apps with product ID, lifecycle state, level, quality, marketing, retention, customers, and last simulation timestamp.
- Config version and a deterministic simulation/replay seed.
- Accumulated passive income eligible for display/claim and the last active-tap result context.
- Product build timestamps, fixed/customer/campaign cost inputs, category/tier/complexity, XP, achievements, season modifier, and paid-effect exclusions.
- A journal/replay sequence or equivalent action identity needed to prevent duplicate offline claims and grants.

### Income

- An active app exposes an hourly income rate in integer cents after configured rounding.
- Aggregate portfolio rate is the sum of all eligible active app rates.
- An app that is paused or retired contributes no income.
- Passive elapsed income is proportional to elapsed seconds, bounded by the configured catch-up cap when the action is offline.
- Foreground simulation advances in configured ticks and caps elapsed work to prevent pathological catch-up loops.
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
8. Reference starting state, token regeneration, creation costs, upgrade curves, progression unlocks, customer cap, and season score weights are exercised by tests.
9. Store/paid effects are represented as non-ranked inputs and cannot alter ranked score inputs.
10. All focused and full Xcode tests pass without UI, network, or database access.

## Open questions

- Whether the active-tap parity target remains fixed at 100 taps/hour or becomes a curve by portfolio size.
- Whether fractional cent display is allowed for active taps or whether sub-cent rewards accumulate as an internal remainder.
- The exact customer/retention/marketing formula beyond the reference baseline.
- The maximum checked arithmetic policy when a very large portfolio approaches `Int64.max`.

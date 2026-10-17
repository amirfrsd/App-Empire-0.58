import Foundation

struct EconomyEngine: Sendable {
    let config: EconomyConfig
    let tapTargetPerHour: Int

    init(config: EconomyConfig, tapTargetPerHour: Int = 100) {
        self.config = config
        self.tapTargetPerHour = max(1, tapTargetPerHour)
    }

    func hourlyRate(for app: OwnedApp) -> Int64 {
        guard app.lifecycle == .launched else { return 0 }
        let qualityMultiplier = 1.0 + (Double(app.qualityLevel) * 0.08)
        let marketingMultiplier = 1.0 + (Double(app.marketingLevel) * 0.12)
        let raw = Double(app.baseHourlyIncomeCents * Int64(max(1, app.level)))
            * qualityMultiplier
            * marketingMultiplier
        return max(0, Int64(raw.rounded(.toNearestOrAwayFromZero)))
    }

    func portfolioHourlyRate(in state: PlayerState) -> Int64 {
        state.apps.reduce(into: Int64.zero) { total, app in
            total = total.addingReportingOverflow(hourlyRate(for: app)).partialValue
        }
    }

    func apply(_ action: EconomyAction, to originalState: PlayerState) throws -> EconomyResult {
        let actionID = action.id
        guard !originalState.appliedActionIDs.contains(actionID) else {
            throw EconomyError.duplicateAction
        }

        var state = originalState
        state.appliedActionIDs.insert(actionID)

        let summary: EconomySummary
        switch action {
        case .tap:
            let rate = portfolioHourlyRate(in: state)
            guard rate > 0 else { throw EconomyError.noEligibleApps }
            let reward = rate / Int64(tapTargetPerHour)
            state.cashCents = try adding(state.cashCents, reward)
            summary = EconomySummary(cashDeltaCents: reward, tapRewardCents: reward, passiveIncomeCents: 0, elapsedSeconds: 0)

        case let .advance(seconds, offline, _):
            guard seconds >= 0 else { throw EconomyError.invalidElapsedTime }
            if offline && seconds > config.offline.maxCatchupHours * 3600 {
                state.lastSimulatedAt += TimeInterval(config.offline.maxCatchupHours * 3600)
            }
            let effectiveSeconds = offline ? min(seconds, config.offline.maxCatchupHours * 3600) : seconds
            if offline && effectiveSeconds < config.offline.minimumClaimSeconds && effectiveSeconds > 0 {
                throw EconomyError.offlineCatchupTooShort
            }
            let income = try elapsedIncome(rate: portfolioHourlyRate(in: state), seconds: effectiveSeconds)
            state.cashCents = try adding(state.cashCents, income)
            state.aiTokens = min(30, state.aiTokens + effectiveSeconds / 1800)
            state.lastSimulatedAt += TimeInterval(effectiveSeconds)
            summary = EconomySummary(cashDeltaCents: income, tapRewardCents: 0, passiveIncomeCents: income, elapsedSeconds: effectiveSeconds)

        case let .upgradeQuality(appID, _):
            guard let index = state.apps.firstIndex(where: { $0.id == appID }) else { throw EconomyError.appNotFound }
            let app = state.apps[index]
            guard app.qualityLevel < 10 else { throw EconomyError.invalidUpgrade }
            let level = app.qualityLevel
            let cost = Int64((12000.0 * pow(1.55, Double(level))).rounded(.toNearestOrAwayFromZero))
            guard state.cashCents >= cost else { throw EconomyError.insufficientCash }
            state.cashCents -= cost
            state.apps[index].qualityLevel += 1
            summary = EconomySummary(cashDeltaCents: -cost, tapRewardCents: 0, passiveIncomeCents: 0, elapsedSeconds: 0)
        }

        return EconomyResult(state: state, summary: summary)
    }

    private func elapsedIncome(rate: Int64, seconds: Int) throws -> Int64 {
        let product = rate.multipliedReportingOverflow(by: Int64(seconds))
        guard !product.overflow else { throw EconomyError.overflow }
        return product.partialValue / 3600
    }

    private func adding(_ lhs: Int64, _ rhs: Int64) throws -> Int64 {
        let result = lhs.addingReportingOverflow(rhs)
        guard !result.overflow else { throw EconomyError.overflow }
        return result.partialValue
    }
}

private extension EconomyAction {
    var id: String {
        switch self {
        case let .tap(id), let .advance(_, _, id), let .upgradeQuality(_, id): return id
        }
    }
}

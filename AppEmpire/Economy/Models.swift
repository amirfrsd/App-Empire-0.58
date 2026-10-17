import Foundation

enum AppLifecycle: String, Codable, Sendable {
    case draft
    case building
    case launched
    case paused
    case retired
}

struct OwnedApp: Codable, Equatable, Sendable, Identifiable {
    let id: UUID
    let productID: String
    var lifecycle: AppLifecycle
    var level: Int
    var qualityLevel: Int
    var retentionLevel: Int
    var marketingLevel: Int
    var customers: Int64
    var baseHourlyIncomeCents: Int64
    var lastSimulatedAt: TimeInterval

    init(
        id: UUID = UUID(),
        productID: String,
        lifecycle: AppLifecycle = .launched,
        level: Int = 1,
        qualityLevel: Int = 0,
        retentionLevel: Int = 0,
        marketingLevel: Int = 0,
        customers: Int64 = 0,
        baseHourlyIncomeCents: Int64 = 200,
        lastSimulatedAt: TimeInterval = 0
    ) {
        self.id = id
        self.productID = productID
        self.lifecycle = lifecycle
        self.level = level
        self.qualityLevel = qualityLevel
        self.retentionLevel = retentionLevel
        self.marketingLevel = marketingLevel
        self.customers = customers
        self.baseHourlyIncomeCents = baseHourlyIncomeCents
        self.lastSimulatedAt = lastSimulatedAt
    }
}

struct PlayerState: Codable, Equatable, Sendable {
    var cashCents: Int64
    var gems: Int
    var aiTokens: Int
    var founderLevel: Int
    var founderXP: Int
    var productSlots: Int
    var apps: [OwnedApp]
    var configVersion: String
    var lastSimulatedAt: TimeInterval
    var appliedActionIDs: Set<String>

    static func starter(configVersion: String = "1.0.0") -> PlayerState {
        PlayerState(
            cashCents: 90_000,
            gems: 0,
            aiTokens: 12,
            founderLevel: 1,
            founderXP: 0,
            productSlots: 1,
            apps: [],
            configVersion: configVersion,
            lastSimulatedAt: 0,
            appliedActionIDs: []
        )
    }
}

enum EconomyAction: Equatable, Sendable {
    case tap(id: String)
    case advance(seconds: Int, offline: Bool, id: String)
    case upgradeQuality(appID: UUID, id: String)
}

struct EconomySummary: Equatable, Sendable {
    let cashDeltaCents: Int64
    let tapRewardCents: Int64
    let passiveIncomeCents: Int64
    let elapsedSeconds: Int
}

struct EconomyResult: Equatable, Sendable {
    let state: PlayerState
    let summary: EconomySummary
}

enum EconomyError: Error, Equatable {
    case duplicateAction
    case invalidElapsedTime
    case offlineCatchupTooShort
    case noEligibleApps
    case appNotFound
    case invalidUpgrade
    case insufficientCash
    case overflow
}

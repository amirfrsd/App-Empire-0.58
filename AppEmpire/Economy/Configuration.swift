import Foundation

struct EconomyConfig: Decodable, Sendable {
    let configVersion: String
    let startingState: StartingState
    let offline: OfflineConfig
    let simulation: SimulationConfig

    enum CodingKeys: String, CodingKey {
        case configVersion = "config_version"
        case startingState = "starting_state"
        case offline
        case simulation
    }
}

struct StartingState: Decodable, Sendable {
    let cashCents: Int64
    let aiTokens: Int
    let gems: Int
    let founderLevel: Int
    let productSlots: Int

    enum CodingKeys: String, CodingKey {
        case cashCents = "cash_cents"
        case aiTokens = "ai_tokens"
        case gems
        case founderLevel = "founder_level"
        case productSlots = "product_slots"
    }
}

struct OfflineConfig: Decodable, Sendable {
    let maxCatchupHours: Int
    let minimumClaimSeconds: Int

    enum CodingKeys: String, CodingKey {
        case maxCatchupHours = "max_catchup_hours"
        case minimumClaimSeconds = "minimum_claim_seconds"
    }
}

struct SimulationConfig: Decodable, Sendable {
    let tickSeconds: Int
    let customerCapPerProduct: Int64
    let baseArpuCents: Int
    let baseChurnDaily: Double

    enum CodingKeys: String, CodingKey {
        case tickSeconds = "tick_seconds"
        case customerCapPerProduct = "customer_cap_per_product"
        case baseArpuCents = "base_arpu_cents"
        case baseChurnDaily = "base_churn_daily"
    }
}

struct ProductCatalog: Decodable, Sendable {
    let catalogVersion: String
    let productCount: Int
    let products: [ProductSeed]

    enum CodingKeys: String, CodingKey {
        case catalogVersion = "catalog_version"
        case productCount = "product_count"
        case products
    }
}

struct ProductSeed: Decodable, Identifiable, Sendable {
    let id: String
    let name: String
    let category: String
    let categoryLabel: String
    let tier: String
    let description: String
    let buildCostCents: Int64
    let aiTokenCost: Int
    let buildTimeHours: Int
    let baseDemandMultiplier: Double
    let baseArpuCents: Int
    let baseChurnDaily: Double
    let complexity: Int
    let productType: String
    let platform: String
    let businessModel: String
    let targetCustomer: String

    enum CodingKeys: String, CodingKey {
        case id, name, category, tier, description, complexity, platform
        case productType = "product_type"
        case businessModel = "business_model"
        case targetCustomer = "target_customer"
        case categoryLabel = "category_label"
        case buildCostCents = "build_cost_cents"
        case aiTokenCost = "ai_token_cost"
        case buildTimeHours = "build_time_hours"
        case baseDemandMultiplier = "base_demand_multiplier"
        case baseArpuCents = "base_arpu_cents"
        case baseChurnDaily = "base_churn_daily"
    }
}

enum ConfigurationError: Error, Equatable {
    case invalidCatalogCount(expected: Int, actual: Int)
    case duplicateProductIDs
    case invalidProduct(id: String)
}

enum ConfigurationLoader {
    static func loadEconomy(from url: URL) throws -> EconomyConfig {
        try JSONDecoder().decode(EconomyConfig.self, from: Data(contentsOf: url))
    }

    static func loadCatalog(from url: URL) throws -> ProductCatalog {
        let catalog = try JSONDecoder().decode(ProductCatalog.self, from: Data(contentsOf: url))

        guard catalog.productCount == catalog.products.count else {
            throw ConfigurationError.invalidCatalogCount(expected: catalog.productCount, actual: catalog.products.count)
        }
        guard Set(catalog.products.map(\.id)).count == catalog.products.count else {
            throw ConfigurationError.duplicateProductIDs
        }
        guard catalog.products.allSatisfy({ $0.buildCostCents > 0 && $0.aiTokenCost > 0 }) else {
            let invalidID = catalog.products.first(where: { $0.buildCostCents <= 0 || $0.aiTokenCost <= 0 })?.id ?? "unknown"
            throw ConfigurationError.invalidProduct(id: invalidID)
        }

        return catalog
    }
}

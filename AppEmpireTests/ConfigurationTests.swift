import Foundation
import XCTest
@testable import AppEmpire

final class ConfigurationTests: XCTestCase {
    func testReferenceCatalogContains120UniqueProducts() throws {
        let catalog = try ConfigurationLoader.loadCatalog(from: resourceURL(named: "products"))

        XCTAssertEqual(catalog.products.count, 120)
        XCTAssertEqual(Set(catalog.products.map(\.id)).count, 120)
        XCTAssertEqual(catalog.products.first?.id, "product_001")
        XCTAssertEqual(catalog.products.last?.id, "product_120")
    }

    func testReferenceEconomyHasStartingStateAndTapConfiguration() throws {
        let economy = try ConfigurationLoader.loadEconomy(from: resourceURL(named: "economy"))

        XCTAssertEqual(economy.configVersion, "1.0.0")
        XCTAssertEqual(economy.startingState.cashCents, 90_000)
        XCTAssertEqual(economy.startingState.aiTokens, 12)
        XCTAssertEqual(economy.offline.maxCatchupHours, 8)
    }

    private func resourceURL(named name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppEmpire/Resources")
            .appendingPathComponent("\(name).json")
    }
}

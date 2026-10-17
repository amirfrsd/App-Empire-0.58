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
        XCTAssertEqual(Set(catalog.products.map(\.productType)), Set(["mobile", "saas"]))
        XCTAssertTrue(catalog.products.allSatisfy { !$0.platform.isEmpty && !$0.businessModel.isEmpty && !$0.targetCustomer.isEmpty })
    }

    func testReferenceEconomyHasStartingStateAndTapConfiguration() throws {
        let economy = try ConfigurationLoader.loadEconomy(from: resourceURL(named: "economy"))

        XCTAssertEqual(economy.configVersion, "1.0.0")
        XCTAssertEqual(economy.startingState.cashCents, 90_000)
        XCTAssertEqual(economy.startingState.aiTokens, 10)
        XCTAssertEqual(economy.startingState.gems, 5)
        XCTAssertEqual(economy.offline.maxCatchupHours, 8)
    }

    func testBundledEconomyAndProductResourcesMatchPinnedHashes() throws {
        for (name, hash) in ResourceIntegrity.expectedHashes {
            let url = resourceURL(named: name.replacingOccurrences(of: ".json", with: ""))
            try ResourceIntegrity.verify(resourceAt: url, expectedHash: hash)
        }
    }

    func testModifiedResourceIsRejected() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("economy.json")
        try Data("tampered".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertThrowsError(try ResourceIntegrity.verify(resourceAt: url, expectedHash: ResourceIntegrity.expectedHashes["economy.json"]!)) { error in
            guard case let ResourceIntegrityError.hashMismatch(resource, _, _) = error else {
                return XCTFail("Expected a hash mismatch")
            }
            XCTAssertEqual(resource, "economy.json")
        }
    }

    private func resourceURL(named name: String) -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppEmpire/Resources")
            .appendingPathComponent("\(name).json")
    }
}

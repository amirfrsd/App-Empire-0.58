import XCTest
@testable import AppEmpire

final class EconomyEngineTests: XCTestCase {
    private var engine: EconomyEngine!

    override func setUp() {
        let economyURL = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("AppEmpire/Resources/economy.json")
        let config = try! ConfigurationLoader.loadEconomy(from: economyURL)
        engine = EconomyEngine(config: config, tapTargetPerHour: 100)
    }

    func testTwoEightDollarAppsHaveSixteenDollarHourlyPortfolioRate() {
        let state = PlayerState(cashCents: 0, gems: 0, aiTokens: 0, founderLevel: 1, founderXP: 0, productSlots: 2, apps: [
            OwnedApp(productID: "a", level: 4),
            OwnedApp(productID: "b", level: 4)
        ], configVersion: "1.0.0", lastSimulatedAt: 0, appliedActionIDs: [])

        XCTAssertEqual(engine.portfolioHourlyRate(in: state), 1600)
    }

    func testTapAwardsSixteenCentsForTwoEightDollarApps() throws {
        let state = stateWithTwoLevelFourApps()
        let result = try engine.apply(.tap(id: "tap-1"), to: state)

        XCTAssertEqual(result.summary.tapRewardCents, 16)
        XCTAssertEqual(result.state.cashCents, 16)
    }

    func testFourEightDollarAppsHaveThirtyTwoDollarHourlyRate() {
        let apps = (0..<4).map { OwnedApp(productID: "app-\($0)", level: 4) }
        let state = PlayerState(cashCents: 0, gems: 0, aiTokens: 0, founderLevel: 1, founderXP: 0, productSlots: 4, apps: apps, configVersion: "1.0.0", lastSimulatedAt: 0, appliedActionIDs: [])

        XCTAssertEqual(engine.portfolioHourlyRate(in: state), 3200)
    }

    func testHourlyPassiveIncomeUsesElapsedSeconds() throws {
        let result = try engine.apply(.advance(seconds: 3600, offline: false, id: "advance-1"), to: stateWithTwoLevelFourApps())

        XCTAssertEqual(result.summary.passiveIncomeCents, 1600)
        XCTAssertEqual(result.state.cashCents, 1600)
    }

    func testOfflineIncomeIsCappedAtEightHours() throws {
        let result = try engine.apply(.advance(seconds: 9 * 3600, offline: true, id: "offline-1"), to: stateWithTwoLevelFourApps())

        XCTAssertEqual(result.summary.elapsedSeconds, 8 * 3600)
        XCTAssertEqual(result.summary.passiveIncomeCents, 12_800)
    }

    func testRejectedDuplicateActionDoesNotChangeState() throws {
        let state = stateWithTwoLevelFourApps()
        let first = try engine.apply(.tap(id: "same"), to: state)

        XCTAssertThrowsError(try engine.apply(.tap(id: "same"), to: first.state)) { error in
            XCTAssertEqual(error as? EconomyError, .duplicateAction)
        }
    }

    func testPausedAndRetiredAppsDoNotEarn() throws {
        let apps = [
            OwnedApp(productID: "paused", lifecycle: .paused, level: 4),
            OwnedApp(productID: "retired", lifecycle: .retired, level: 4)
        ]
        let state = PlayerState(cashCents: 0, gems: 0, aiTokens: 0, founderLevel: 1, founderXP: 0, productSlots: 2, apps: apps, configVersion: "1.0.0", lastSimulatedAt: 0, appliedActionIDs: [])

        XCTAssertEqual(engine.portfolioHourlyRate(in: state), 0)
        XCTAssertThrowsError(try engine.apply(.tap(id: "no-income"), to: state))
    }

    private func stateWithTwoLevelFourApps() -> PlayerState {
        PlayerState(cashCents: 0, gems: 0, aiTokens: 0, founderLevel: 1, founderXP: 0, productSlots: 2, apps: [
            OwnedApp(productID: "a", level: 4),
            OwnedApp(productID: "b", level: 4)
        ], configVersion: "1.0.0", lastSimulatedAt: 0, appliedActionIDs: [])
    }
}

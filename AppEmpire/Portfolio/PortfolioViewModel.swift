import Foundation
import SwiftUI

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var state: PlayerState
    @Published private(set) var lastTapRewardCents: Int64 = 0
    @Published var showTutorial = false

    let engine: EconomyEngine

    init() {
        let economyURL = Bundle.main.url(forResource: "economy", withExtension: "json")!
        let config = try! ConfigurationLoader.loadEconomy(from: economyURL)
        self.engine = EconomyEngine(config: config)
        self.state = .starter(configVersion: config.configVersion)
        self.showTutorial = true
    }

    var portfolioHourlyRate: Int64 {
        engine.portfolioHourlyRate(in: state)
    }

    var hasLaunchedApp: Bool {
        state.apps.contains { $0.lifecycle == .launched }
    }

    func launchStarterApp() {
        guard !hasLaunchedApp else {
            showTutorial = false
            return
        }
        state.apps = [OwnedApp(productID: "product_001", lifecycle: .launched, level: 1)]
        showTutorial = false
    }

    func tapToEarn() {
        guard let result = try? engine.apply(.tap(id: UUID().uuidString), to: state) else { return }
        state = result.state
        lastTapRewardCents = result.summary.tapRewardCents
    }

    func upgradeStarterApp() {
        guard let app = state.apps.first,
              let result = try? engine.apply(.upgradeQuality(appID: app.id, id: UUID().uuidString), to: state)
        else { return }
        state = result.state
    }
}

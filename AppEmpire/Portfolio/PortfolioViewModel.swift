import Foundation
import SwiftUI

@MainActor
final class PortfolioViewModel: ObservableObject {
    @Published private(set) var state: PlayerState
    @Published private(set) var lastTapRewardCents: Int64 = 0
    @Published var showTutorial = false
    @Published var offlineSummary: EconomySummary?

    let engine: EconomyEngine
    private let store: PlayerStore
    private var lastSavedAt: Date

    init() {
        try! ResourceIntegrity.verifyBundledResources()
        let economyURL = Bundle.main.url(forResource: "economy", withExtension: "json")!
        let config = try! ConfigurationLoader.loadEconomy(from: economyURL)
        self.engine = EconomyEngine(config: config)
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("AppEmpire", isDirectory: true)
        self.store = try! PlayerStore(directory: directory)
        if let snapshot = try? store.loadSnapshot() {
            self.state = snapshot.state
            self.lastSavedAt = snapshot.savedAt
            self.showTutorial = snapshot.state.apps.isEmpty
        } else {
            self.state = .starter(configVersion: config.configVersion)
            self.lastSavedAt = Date()
            self.showTutorial = true
        }
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
        persist()
    }

    func tapToEarn() {
        guard let result = try? engine.apply(.tap(id: UUID().uuidString), to: state) else { return }
        state = result.state
        lastTapRewardCents = result.summary.tapRewardCents
        persist()
    }

    func upgradeStarterApp() {
        guard let app = state.apps.first,
              let result = try? engine.apply(.upgradeQuality(appID: app.id, id: UUID().uuidString), to: state)
        else { return }
        state = result.state
        persist()
    }

    func handleScenePhase(_ phase: ScenePhase) {
        if phase == .background || phase == .inactive {
            persist()
        } else if phase == .active {
            applyOfflineCatchup()
        }
    }

    private func applyOfflineCatchup() {
        let elapsed = max(0, Int(Date().timeIntervalSince(lastSavedAt)))
        guard elapsed >= engine.config.offline.minimumClaimSeconds else { return }
        guard let result = try? engine.apply(.advance(seconds: elapsed, offline: true, id: "offline-\(UUID().uuidString)"), to: state) else {
            persist()
            return
        }
        state = result.state
        offlineSummary = result.summary
        persist()
    }

    private func persist() {
        do {
            try store.save(state)
            lastSavedAt = Date()
        } catch {
            assertionFailure("Unable to save App Empire: \(error)")
        }
    }
}

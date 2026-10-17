import SwiftUI

struct RootTabView: View {
    @StateObject private var portfolioModel = PortfolioViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView {
            HomeView(model: portfolioModel)
                .tabItem { Label("Home", systemImage: "house.fill") }
            ProductsView(model: portfolioModel)
                .tabItem { Label("Products", systemImage: "square.stack.3d.up.fill") }
            PlaceholderTab(title: "Market", symbol: "chart.line.uptrend.xyaxis")
                .tabItem { Label("Market", systemImage: "chart.line.uptrend.xyaxis") }
            PlaceholderTab(title: "Season", symbol: "trophy.fill")
                .tabItem { Label("Season", systemImage: "trophy.fill") }
            PlaceholderTab(title: "Profile", symbol: "person.crop.circle.fill")
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        .tint(AppColors.lime)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackgroundVisibility(.visible, for: .tabBar)
        .toolbarColorScheme(.dark, for: .tabBar)
        .onChange(of: scenePhase) { _, phase in
            portfolioModel.handleScenePhase(phase)
        }
        .alert("Welcome back", isPresented: Binding(
            get: { portfolioModel.offlineSummary != nil },
            set: { if !$0 { portfolioModel.offlineSummary = nil } }
        )) {
            Button("Collect") { portfolioModel.offlineSummary = nil }
        } message: {
            if let summary = portfolioModel.offlineSummary {
                Text("Your apps earned \(summary.passiveIncomeCents / 100) dollars while you were away.")
            }
        }
    }
}

private struct PlaceholderTab: View {
    let title: String
    let symbol: String

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: symbol)
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(AppColors.lime)
                        .accessibilityHidden(true)
                    Text(title)
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppColors.mainText)
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your empire is getting ready.")
                                .font(.headline)
                                .foregroundStyle(AppColors.mainText)
                            Text("Build, launch, and grow your first app.")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 36)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
    }
}

enum AppColors {
    static let background = Color(red: 5 / 255, green: 52 / 255, blue: 39 / 255)
    static let surface = Color(red: 9 / 255, green: 73 / 255, blue: 52 / 255)
    static let raisedSurface = Color(red: 14 / 255, green: 91 / 255, blue: 65 / 255)
    static let lime = Color(red: 181 / 255, green: 246 / 255, blue: 73 / 255)
    static let ink = Color(red: 0 / 255, green: 29 / 255, blue: 19 / 255)
    static let mainText = Color(red: 232 / 255, green: 250 / 255, blue: 227 / 255)
}

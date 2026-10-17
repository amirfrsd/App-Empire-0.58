import SwiftUI

struct ProductsView: View {
    @ObservedObject var model: PortfolioViewModel

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Products")
                        .font(.largeTitle.bold())
                        .foregroundStyle(AppColors.mainText)
                    if model.state.apps.isEmpty {
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your product studio is empty.")
                                    .font(.headline)
                                    .foregroundStyle(AppColors.mainText)
                                Text("Start with the guided starter app, then grow your portfolio from here.")
                                    .foregroundStyle(AppColors.mainText.opacity(0.72))
                                Button("Launch starter app") {
                                    model.launchStarterApp()
                                }
                                .buttonStyle(PrimaryActionButtonStyle())
                            }
                        }
                    } else {
                        ForEach(model.state.apps) { app in
                            GlassSurface {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(app.productID.replacingOccurrences(of: "product_", with: "App "))
                                            .font(.title3.bold())
                                            .foregroundStyle(AppColors.mainText)
                                        Spacer()
                                        Text("Level \(app.level)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(AppColors.lime)
                                    }
                                    Text("$\(model.engine.hourlyRate(for: app) / 100)/hour")
                                        .font(.title2.bold())
                                        .foregroundStyle(AppColors.mainText)
                                    Button("Improve quality") {
                                        model.upgradeStarterApp()
                                    }
                                    .buttonStyle(PrimaryActionButtonStyle())
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

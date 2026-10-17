import SwiftUI

struct StoreView: View {
    @ObservedObject var model: PortfolioViewModel
    @State private var showingUnavailableAlert = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Store").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    ResourceBalanceStrip(model: model)
                    Text("Power up your empire").font(.title3).foregroundStyle(AppColors.lime)
                    Text("Gems, passes, and founder conveniences.").foregroundStyle(AppColors.mainText.opacity(0.72))

                    StoreSection(title: "Gems", symbol: "diamond.fill", tint: .cyan) {
                        StoreOffer(title: "Starter gem pack", detail: "100 Gems", price: "Purchase") { showingUnavailableAlert = true }
                        StoreOffer(title: "Founder gem pack", detail: "550 Gems · bonus included", price: "Purchase") { showingUnavailableAlert = true }
                        StoreOffer(title: "Empire gem pack", detail: "1,200 Gems · best value", price: "Purchase") { showingUnavailableAlert = true }
                    }
                    StoreSection(title: "Passes", symbol: "ticket.fill", tint: AppColors.lime) {
                        StoreOffer(title: "VIP Pass", detail: "Monthly founder conveniences and cosmetics", price: "Learn more") { showingUnavailableAlert = true }
                        StoreOffer(title: "Season Pass", detail: "Extra rewards for the current season", price: "Learn more") { showingUnavailableAlert = true }
                    }
                    GlassSurface {
                        Label("Purchases are not connected yet", systemImage: "wifi.slash")
                            .font(.headline).foregroundStyle(AppColors.mainText)
                        Text("The offline game remains fully playable. StoreKit and verified purchase grants will be connected in the commerce slice.")
                            .font(.subheadline).foregroundStyle(AppColors.mainText.opacity(0.72))
                            .padding(.top, 6)
                    }
                }.padding(20)
            }
        }
        .alert("Store coming soon", isPresented: $showingUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Purchases will be enabled after StoreKit verification and backend grants are connected.")
        }
    }
}

private struct StoreSection<Content: View>: View {
    let title: String
    let symbol: String
    let tint: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: symbol).font(.headline).foregroundStyle(tint)
            GlassSurface { VStack(spacing: 0) { content } }
        }
    }
}

private struct StoreOffer: View {
    let title: String
    let detail: String
    let price: String
    let action: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(AppColors.mainText)
                Text(detail).font(.caption).foregroundStyle(AppColors.mainText.opacity(0.7))
            }
            Spacer()
            Button(price, action: action)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppColors.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(AppColors.lime, in: Capsule())
        }
        .padding(.vertical, 12)
    }
}

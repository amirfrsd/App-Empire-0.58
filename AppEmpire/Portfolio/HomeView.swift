import SwiftUI

struct HomeView: View {
    @ObservedObject var model: PortfolioViewModel
    @State private var tapPopup: String?
    @State private var tapPopupID = UUID()
    @State private var tapPopupPosition = CGPoint(x: 160, y: 30)
    @State private var tapPopupRotation: Double = 0

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    ResourceBalanceStrip(model: model)
                    cashCard
                    rateCard
                    tapCard
                    portfolioCard
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fullScreenCover(isPresented: $model.showTutorial) {
            TutorialView(model: model)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Good evening, Founder")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.lime)
            Text("Build your next big thing.")
                .font(.largeTitle.bold())
                .foregroundStyle(AppColors.mainText)
        }
        .accessibilityElement(children: .combine)
    }

    private var rateCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 8) {
                Text("Portfolio income")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.mainText.opacity(0.7))
                Text("$\(model.portfolioHourlyRate / 100)/hour")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.mainText)
                Text("Across \(model.state.apps.count) active app\(model.state.apps.count == 1 ? "" : "s")")
                    .foregroundStyle(AppColors.mainText.opacity(0.72))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var cashCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 6) {
                Text("Available cash")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.mainText.opacity(0.7))
                Text(MoneyFormatter.cents(model.state.cashCents))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.lime)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var tapCard: some View {
        GlassSurface {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Active earnings")
                            .font(.headline)
                            .foregroundStyle(AppColors.mainText)
                        Text("Tap to grow your cash")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.mainText.opacity(0.7))
                    }
                    Spacer()
                    Text("+\(MoneyFormatter.cents(model.lastTapRewardCents))")
                        .font(.title2.bold())
                        .foregroundStyle(AppColors.lime)
                }
                ZStack(alignment: .topLeading) {
                    Button("Tap to Earn") {
                    model.tapToEarn()
                        tapPopupID = UUID()
                        tapPopup = "+\(MoneyFormatter.cents(model.lastTapRewardCents))"
                        tapPopupRotation = Double.random(in: -8...8)
                        withAnimation(.easeOut(duration: 0.7)) { }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                            withAnimation(.easeIn(duration: 0.2)) { tapPopup = nil }
                        }
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .disabled(!model.hasLaunchedApp)
                    .accessibilityHint("Adds active earnings from all launched apps")
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { value in
                                tapPopupPosition = CGPoint(
                                    x: min(max(value.location.x, 48), 300),
                                    y: min(max(value.location.y, 22), 66)
                                )
                            }
                    )

                    if let tapPopup {
                        Text(tapPopup)
                            .id(tapPopupID)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppColors.ink)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(AppColors.lime, in: Capsule())
                            .rotationEffect(.degrees(tapPopupRotation))
                            .position(x: tapPopupPosition.x, y: tapPopupPosition.y)
                            .transition(.asymmetric(insertion: .scale(scale: 0.7).combined(with: .opacity), removal: .scale(scale: 1.15).combined(with: .opacity)))
                    }
                }
            }
        }
    }

    private var portfolioCard: some View {
        GlassSurface {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your portfolio")
                    .font(.headline)
                    .foregroundStyle(AppColors.mainText)
                ForEach(model.state.apps) { app in
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.productID.replacingOccurrences(of: "product_", with: "App "))
                                .font(.headline)
                                .foregroundStyle(AppColors.mainText)
                            Text("Level \(app.level) · $\(model.engine.hourlyRate(for: app) / 100)/hour")
                                .font(.subheadline)
                                .foregroundStyle(AppColors.mainText.opacity(0.7))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(AppColors.lime)
                            .accessibilityHidden(true)
                    }
                }
                if model.state.apps.isEmpty {
                    Text("Launch your first app to begin earning.")
                        .foregroundStyle(AppColors.mainText.opacity(0.7))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

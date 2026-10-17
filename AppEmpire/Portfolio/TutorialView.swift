import SwiftUI

struct TutorialView: View {
    @ObservedObject var model: PortfolioViewModel

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Capsule()
                        .fill(AppColors.mainText.opacity(0.25))
                        .frame(width: 44, height: 5)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundStyle(AppColors.lime)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Launch your first app")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.mainText)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("Start with one focused product. Watch its hourly income grow, then tap to accelerate your empire.")
                            .font(.body)
                            .foregroundStyle(AppColors.mainText.opacity(0.76))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    GlassSurface {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your first move")
                                .font(.headline)
                                .foregroundStyle(AppColors.mainText)
                            Text("Launch an app to unlock your portfolio and start earning passive income.")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button("Launch starter app") {
                        model.launchStarterApp()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .preferredColorScheme(.dark)
    }
}

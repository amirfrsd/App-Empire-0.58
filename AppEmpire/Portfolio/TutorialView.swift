import SwiftUI

struct TutorialView: View {
    @ObservedObject var model: PortfolioViewModel

    var body: some View {
        ZStack {
            AppColors.surface.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.lime)
                    .accessibilityHidden(true)
                Text("Launch your first app")
                    .font(.title.bold())
                    .foregroundStyle(AppColors.mainText)
                Text("Start with one focused product. Watch its hourly income grow, then tap to accelerate your empire.")
                    .foregroundStyle(AppColors.mainText.opacity(0.76))
                Spacer()
                Button("Launch starter app") {
                    model.launchStarterApp()
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
            .padding(24)
        }
    }
}

import SwiftUI

struct OfflineEarningsView: View {
    let summary: EconomySummary
    let onCollect: () -> Void
    let onCollectDouble: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(spacing: 24) {
                Spacer()
                ZStack {
                    Circle().fill(AppColors.lime.opacity(0.16)).frame(width: 132, height: 132)
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 68)).foregroundStyle(AppColors.lime)
                }
                Text("Welcome back, Founder")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.mainText)
                    .multilineTextAlignment(.center)
                Text("Your empire kept working while you were away.")
                    .foregroundStyle(AppColors.mainText.opacity(0.72))
                    .multilineTextAlignment(.center)
                GlassSurface {
                    VStack(spacing: 12) {
                        Text("Offline earnings")
                            .font(.headline).foregroundStyle(AppColors.mainText.opacity(0.75))
                        Text(MoneyFormatter.cents(summary.passiveIncomeCents))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.lime)
                        Text("for \(formattedDuration(summary.elapsedSeconds))")
                            .font(.subheadline).foregroundStyle(AppColors.mainText.opacity(0.7))
                    }.frame(maxWidth: .infinity)
                }
                Spacer()
                VStack(spacing: 12) {
                    Button("Collect 2×") { onCollectDouble() }
                        .buttonStyle(PrimaryActionButtonStyle())
                    Button("Collect") { onCollect() }
                        .foregroundStyle(AppColors.mainText.opacity(0.75))
                }
            }
            .padding(24)
        }
        .preferredColorScheme(.dark)
    }

    private func formattedDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 { return "\(hours)h \(minutes)m" }
        return "\(max(1, minutes))m"
    }
}

import SwiftUI

struct ResourceBalanceStrip: View {
    @ObservedObject var model: PortfolioViewModel

    var body: some View {
        HStack(spacing: 8) {
            resourceChip(symbol: "dollarsign.circle.fill", value: MoneyFormatter.cents(model.state.cashCents), tint: AppColors.lime)
            resourceChip(symbol: "diamond.fill", value: "\(model.state.gems)", tint: .cyan)
            resourceChip(symbol: "sparkles", value: "\(model.state.aiTokens)", tint: .orange)
        }
    }

    private func resourceChip(symbol: String, value: String, tint: Color) -> some View {
        Label(value, systemImage: symbol)
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(AppColors.surface, in: Capsule())
            .lineLimit(1)
    }
}

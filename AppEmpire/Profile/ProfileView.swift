import SwiftUI

struct ProfileView: View {
    @ObservedObject var model: PortfolioViewModel

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Profile").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Founder").font(.title2.bold()).foregroundStyle(AppColors.mainText)
                            Text("Level \(model.state.founderLevel)").foregroundStyle(AppColors.lime)
                            Text("XP \(model.state.founderXP)").foregroundStyle(AppColors.mainText.opacity(0.72))
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Local save active", systemImage: "checkmark.shield.fill").font(.headline).foregroundStyle(AppColors.mainText)
                            Text("Your progress is stored on this iPhone and works without an account or network connection.")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Portfolio summary").font(.headline).foregroundStyle(AppColors.mainText)
                            Text("\(model.state.apps.count) app\(model.state.apps.count == 1 ? "" : "s") · \(MoneyFormatter.cents(model.state.cashCents)) cash")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }.padding(20)
            }
        }
    }
}

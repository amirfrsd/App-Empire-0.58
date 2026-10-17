import SwiftUI

struct SeasonView: View {
    @ObservedObject var model: PortfolioViewModel

    var score: Int { Int(model.portfolioHourlyRate / 10) + model.state.founderXP }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Season").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    ResourceBalanceStrip(model: model)
                    Text("Founder season · Offline standings").foregroundStyle(AppColors.lime)
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Season 01: First Launch").font(.title3.bold()).foregroundStyle(AppColors.mainText)
                            Text("Build the strongest portfolio before the season ends.").foregroundStyle(AppColors.mainText.opacity(0.72))
                            ProgressView(value: min(Double(score) / 1000.0, 1))
                                .tint(AppColors.lime)
                            Text("Score \(score) / 1,000").font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.mainText)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your leaderboard position").font(.headline).foregroundStyle(AppColors.mainText)
                            HStack {
                                Text("#1").font(.system(size: 42, weight: .bold, design: .rounded)).foregroundStyle(AppColors.lime)
                                Spacer()
                                Text("Local season").foregroundStyle(AppColors.mainText.opacity(0.7))
                            }
                            Text("Online rankings will connect here when backend services are enabled.").font(.caption).foregroundStyle(AppColors.mainText.opacity(0.65))
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }.padding(20)
            }
        }
    }
}

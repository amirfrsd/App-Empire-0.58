import SwiftUI

struct MarketView: View {
    @ObservedObject var model: PortfolioViewModel

    private var categories: [(String, [ProductSeed])] {
        Dictionary(grouping: model.catalog.products, by: \.categoryLabel).sorted { $0.key < $1.key }
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Market").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    Text("Find your next opportunity").font(.title3).foregroundStyle(AppColors.lime)
                    GlassSurface {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Offline market", systemImage: "wifi.slash")
                                .font(.headline).foregroundStyle(AppColors.mainText)
                            Text("The market is available offline. Browse every category and launch products directly into your portfolio.")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    ForEach(categories, id: \.0) { category, products in
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text(category).font(.headline).foregroundStyle(AppColors.mainText)
                                    Spacer()
                                    Text("\(products.count) products").font(.caption).foregroundStyle(AppColors.mainText.opacity(0.65))
                                }
                                ForEach(products.prefix(2)) { product in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.name).font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.mainText)
                                            Text(product.description).font(.caption).foregroundStyle(AppColors.mainText.opacity(0.7)).lineLimit(2)
                                        }
                                        Spacer()
                                        Button("Build") { model.launchProduct(product) }
                                            .buttonStyle(PrimaryActionButtonStyle())
                                            .frame(maxWidth: 100)
                                            .disabled(model.state.apps.count >= model.state.productSlots || model.state.cashCents < product.buildCostCents)
                                    }
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }.padding(20)
            }
        }
    }
}

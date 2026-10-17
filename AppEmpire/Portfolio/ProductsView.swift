import SwiftUI

struct ProductsView: View {
    @ObservedObject var model: PortfolioViewModel
    private var categories: [(String, [ProductSeed])] { Dictionary(grouping: model.catalog.products, by: \.categoryLabel).sorted { $0.key < $1.key } }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Products").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    Text("Browse categories").font(.headline).foregroundStyle(AppColors.mainText)
                    ForEach(categories, id: \.0) { category, products in
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(category).font(.headline).foregroundStyle(AppColors.mainText)
                                ForEach(products.prefix(3)) { product in
                                    HStack(spacing: 10) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(product.name).font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.mainText)
                                            Text("\(product.tier.capitalized) · \(MoneyFormatter.cents(product.buildCostCents))").font(.caption).foregroundStyle(AppColors.mainText.opacity(0.7))
                                        }
                                        Spacer()
                                        Button("Launch") { model.launchProduct(product) }
                                            .buttonStyle(PrimaryActionButtonStyle())
                                            .frame(maxWidth: 110)
                                            .disabled(model.state.apps.count >= model.state.productSlots || model.state.cashCents < product.buildCostCents)
                                    }
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    if !model.state.apps.isEmpty {
                        Text("Your portfolio").font(.headline).foregroundStyle(AppColors.mainText)
                        ForEach(model.state.apps) { app in
                            GlassSurface {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(app.productID.replacingOccurrences(of: "product_", with: "App ")).font(.title3.bold()).foregroundStyle(AppColors.mainText)
                                        Spacer()
                                        Text("Level \(app.level)").font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.lime)
                                    }
                                    Text("\(MoneyFormatter.cents(model.engine.hourlyRate(for: app)))/hour").font(.title2.bold()).foregroundStyle(AppColors.mainText)
                                    Button("Improve quality") { model.upgradeStarterApp() }.buttonStyle(PrimaryActionButtonStyle())
                                }.frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }.padding(20)
            }
        }
    }
}

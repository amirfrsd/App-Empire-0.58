import SwiftUI

struct ProductsView: View {
    @ObservedObject var model: PortfolioViewModel
    @State private var showingProductCreator = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Products").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    ResourceBalanceStrip(model: model)
                    Button { showingProductCreator = true } label: { Label("Create new product", systemImage: "plus") }
                        .buttonStyle(PrimaryActionButtonStyle())
                    Text("Active apps").font(.headline).foregroundStyle(AppColors.mainText)
                    let activeApps = model.state.apps.filter { $0.lifecycle == .launched }
                    if activeApps.isEmpty {
                        GlassSurface { Text("No active apps yet. Create your first product to begin building.").foregroundStyle(AppColors.mainText.opacity(0.72)).frame(maxWidth: .infinity, alignment: .leading) }
                    } else {
                        ForEach(activeApps) { app in
                            GlassSurface {
                                VStack(alignment: .leading, spacing: 14) {
                                    HStack {
                                        Text(app.productID.replacingOccurrences(of: "product_", with: "App ")).font(.title3.bold()).foregroundStyle(AppColors.mainText)
                                        Spacer(); Text("Level \(app.level)").font(.subheadline.weight(.semibold)).foregroundStyle(AppColors.lime)
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
        .sheet(isPresented: $showingProductCreator) {
            ProductCreatorView(model: model).presentationDetents([.large]).presentationDragIndicator(.visible)
        }
    }
}

private enum ProductType: String, CaseIterable, Identifiable {
    case mobile = "mobile"
    case saas = "saas"
    var id: String { rawValue }
    var title: String { self == .mobile ? "Mobile app" : "SaaS product" }
    var symbol: String { self == .mobile ? "iphone" : "rectangle.3.group" }
}

private struct ProductCreatorView: View {
    @ObservedObject var model: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                List {
                    Section {
                        Text("Choose a direction, then select a category and product idea.").foregroundStyle(AppColors.mainText.opacity(0.72)).listRowBackground(Color.clear)
                        ForEach(ProductType.allCases) { type in
                            NavigationLink { CategoryPickerView(model: model, type: type, dismissCreator: dismiss) } label: {
                                Label { VStack(alignment: .leading, spacing: 4) { Text(type.title).font(.headline); Text(type == .mobile ? "iPhone-first consumer products" : "Web products for teams and businesses").font(.caption).foregroundStyle(AppColors.mainText.opacity(0.65)) } } icon: { Image(systemName: type.symbol).foregroundStyle(AppColors.lime) }
                            }.listRowBackground(AppColors.surface)
                        }
                    } header: { Text("New product").foregroundStyle(AppColors.lime) }
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("Create product")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Close") { dismiss() }.foregroundStyle(AppColors.lime) } }
        }
    }
}

private struct CategoryPickerView: View {
    @ObservedObject var model: PortfolioViewModel
    let type: ProductType
    let dismissCreator: DismissAction

    private var categories: [String] { Array(Set(model.catalog.products.filter { $0.productType == type.rawValue }.map(\.categoryLabel))).sorted() }

    var body: some View {
        List {
            Section {
                ForEach(categories, id: \.self) { category in
                    NavigationLink { IdeaPickerView(model: model, type: type, category: category, dismissCreator: dismissCreator) } label: { Label(category, systemImage: CategoryPresentation.symbol(for: category)) }.listRowBackground(AppColors.surface)
                }
            } header: { Text("Choose a category").foregroundStyle(AppColors.lime) }
        }.scrollContentBackground(.hidden).background(AppColors.background).navigationTitle(type.title)
    }
}

private struct IdeaPickerView: View {
    @ObservedObject var model: PortfolioViewModel
    let type: ProductType
    let category: String
    let dismissCreator: DismissAction

    private var ideas: [ProductSeed] { model.catalog.products.filter { $0.productType == type.rawValue && $0.categoryLabel == category }.prefix(5).map { $0 } }

    var body: some View {
        List {
            Section {
                ForEach(ideas) { product in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(product.name).font(.headline).foregroundStyle(AppColors.mainText)
                        Text(product.description).font(.subheadline).foregroundStyle(AppColors.mainText.opacity(0.72)).fixedSize(horizontal: false, vertical: true)
                        Text("\(product.platform.uppercased()) · \(product.businessModel.replacingOccurrences(of: "_", with: " ").capitalized) · For \(product.targetCustomer)").font(.caption).foregroundStyle(AppColors.lime.opacity(0.85))
                        HStack {
                            Text("Build \(MoneyFormatter.cents(product.buildCostCents))").font(.caption.weight(.semibold)).foregroundStyle(AppColors.lime)
                            Spacer()
                            Button("Build idea") { model.launchProduct(product); dismissCreator() }.buttonStyle(PrimaryActionButtonStyle()).frame(maxWidth: 130).disabled(model.state.apps.count >= model.state.productSlots || model.state.cashCents < product.buildCostCents)
                        }
                    }.padding(.vertical, 8).listRowBackground(AppColors.surface)
                }
            } header: { Text("Choose an idea · \(category)").foregroundStyle(AppColors.lime) }
        }.scrollContentBackground(.hidden).background(AppColors.background).navigationTitle("Product ideas")
    }
}

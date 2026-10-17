import SwiftUI

struct ProductsView: View {
    @ObservedObject var model: PortfolioViewModel
    @State private var showingProductCreator = false
    private var categories: [(String, [ProductSeed])] { Dictionary(grouping: model.catalog.products, by: \.categoryLabel).sorted { $0.key < $1.key } }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Products").font(.largeTitle.bold()).foregroundStyle(AppColors.mainText)
                    Button {
                        showingProductCreator = true
                    } label: {
                        Label("Create new product", systemImage: "plus")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    Text("Active apps").font(.headline).foregroundStyle(AppColors.mainText)
                    let activeApps = model.state.apps.filter { $0.lifecycle == .launched }
                    if activeApps.isEmpty {
                        GlassSurface {
                            Text("No active apps yet. Create your first product to begin building.")
                                .foregroundStyle(AppColors.mainText.opacity(0.72))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        ForEach(activeApps) { app in
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
        .sheet(isPresented: $showingProductCreator) {
            ProductCreatorView(model: model)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }
}

private enum ProductType: String, CaseIterable, Identifiable {
    case mobile = "Mobile app"
    case saas = "SaaS product"
    var id: String { rawValue }
}

private struct ProductCreatorView: View {
    @ObservedObject var model: PortfolioViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedType: ProductType?
    @State private var selectedCategory: String?

    private var categories: [String] {
        guard let selectedType else { return [] }
        return Array(Set(model.catalog.products.filter { $0.productType == selectedType.rawValue }.map(\.categoryLabel))).sorted()
    }

    private var ideas: [ProductSeed] {
        guard let selectedCategory else { return [] }
        return model.catalog.products.filter { $0.categoryLabel == selectedCategory && $0.productType == selectedType?.rawValue }.prefix(5).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Create a new product")
                            .font(.largeTitle.bold())
                            .foregroundStyle(AppColors.mainText)
                        Text("Choose a direction, then pick an idea to add to your portfolio.")
                            .foregroundStyle(AppColors.mainText.opacity(0.72))

                        Text("1. Choose a type").font(.headline).foregroundStyle(AppColors.mainText)
                        ForEach(ProductType.allCases) { type in
                            selectionRow(title: type.rawValue, symbol: type == .mobile ? "iphone" : "rectangle.3.group", isSelected: selectedType == type) {
                                selectedType = type
                                selectedCategory = nil
                            }
                        }

                        if selectedType != nil {
                            Text("2. Choose a category").font(.headline).foregroundStyle(AppColors.mainText).padding(.top, 8)
                            ForEach(categories, id: \.self) { category in
                                selectionRow(title: category, symbol: "square.grid.2x2", isSelected: selectedCategory == category) {
                                    selectedCategory = category
                                }
                            }
                        }

                        if selectedCategory != nil {
                            Text("3. Choose an app idea").font(.headline).foregroundStyle(AppColors.mainText).padding(.top, 8)
                            ForEach(ideas) { product in
                                GlassSurface {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(product.name).font(.headline).foregroundStyle(AppColors.mainText)
                                        Text(product.description).font(.subheadline).foregroundStyle(AppColors.mainText.opacity(0.72)).fixedSize(horizontal: false, vertical: true)
                                        Text("\(product.platform.uppercased()) · \(product.businessModel.replacingOccurrences(of: "_", with: " ").capitalized) · For \(product.targetCustomer)")
                                            .font(.caption).foregroundStyle(AppColors.lime.opacity(0.85))
                                        HStack {
                                            Text("Build \(MoneyFormatter.cents(product.buildCostCents))")
                                                .font(.caption.weight(.semibold)).foregroundStyle(AppColors.lime)
                                            Spacer()
                                            Button("Build idea") {
                                                model.launchProduct(product)
                                                dismiss()
                                            }
                                            .buttonStyle(PrimaryActionButtonStyle())
                                            .frame(maxWidth: 130)
                                            .disabled(model.state.apps.count >= model.state.productSlots || model.state.cashCents < product.buildCostCents)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }.foregroundStyle(AppColors.lime)
                }
            }
        }
    }

    private func selectionRow(title: String, symbol: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: symbol).foregroundStyle(AppColors.lime)
                Text(title).foregroundStyle(AppColors.mainText)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppColors.lime : AppColors.mainText.opacity(0.4))
            }
            .padding(16)
            .background(AppColors.surface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

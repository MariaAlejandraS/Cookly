import SwiftUI

/// Detalle de Open Food Facts y alta en la nevera.
struct ProductDetailView: View {
    @StateObject private var viewModel: ProductDetailViewModel
    @State private var showAdd = false
    @State private var showSavedToast = false
    @State private var savedCount = 0

    init(product: OFFProduct) {
        _viewModel = StateObject(wrappedValue: ProductDetailViewModel(product: product))
    }

    var body: some View {
        let product = viewModel.product
        ScrollView {
            VStack(alignment: .leading, spacing: CooklyTheme.space16) {
                imageCard(product)
                Text(product.displayName)
                    .font(CooklyTheme.rounded(.title2, weight: .bold))
                    .foregroundStyle(CooklyTheme.ink)
                if let brands = product.brands {
                    Text(brands).foregroundStyle(.secondary)
                }
                chips(product)
                details(product)
                if viewModel.isLoading {
                    ProgressView("Cargando detalle…")
                } else if let error = viewModel.errorMessage {
                    Text(error).font(.footnote).foregroundStyle(CooklyTheme.danger)
                }
                Text("Datos de Open Food Facts (ODbL).")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(CooklyTheme.space16)
        }
        .cooklyScreen()
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            Button { showAdd = true } label: {
                Label("Agregar a mi nevera", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(CooklyTheme.space16)
            .background(.ultraThinMaterial)
        }
        .task { await viewModel.loadDetail() }
        .sheet(isPresented: $showAdd) {
            AddProductView(viewModel: AddProductViewModel(from: viewModel.product), onSaved: {
                savedCount += 1
                showSavedToast = true
            })
        }
        .toast(isPresented: $showSavedToast, message: "Alimento agregado a tu nevera", bottom: 96)
        .sensoryFeedback(.success, trigger: savedCount)
    }

    private func imageCard(_ product: OFFProduct) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous)
                .fill(CooklyTheme.brandGradient)
                .opacity(0.35)
            AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "photo")
                    .font(.system(size: 48))
                    .foregroundStyle(CooklyTheme.brandForeground)
            }
            .frame(maxWidth: .infinity)
            .padding(CooklyTheme.space16)
        }
        .frame(height: 230)
        .clipShape(RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous))
    }

    private func chips(_ product: OFFProduct) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CooklyTheme.space8) {
                if let grade = product.nutriscoreGrade, grade.count == 1 {
                    NutriScoreBadge(grade: grade)
                }
                if let nova = product.novaGroup {
                    Pill(text: "NOVA \(nova)", foreground: CooklyTheme.ink, background: CooklyTheme.surface)
                }
                if let quantity = product.quantity {
                    Pill(text: quantity, foreground: CooklyTheme.ink, background: CooklyTheme.surface)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private func details(_ product: OFFProduct) -> some View {
        let category = FoodCategory.from(offTags: product.categoriesTags ?? [])
        return VStack(alignment: .leading, spacing: CooklyTheme.space16) {
            InfoCard(
                title: "Categoría en Cookly",
                text: "\(category.rawValue). Recomendado: \(category.minDays) a \(category.maxDays) días en refrigeración."
            )
            if let ingredients = product.ingredientsText, !ingredients.isEmpty {
                InfoCard(title: "Ingredientes", text: ingredients)
            }
            if let allergens = product.allergens, !allergens.isEmpty {
                InfoCard(title: "Alérgenos", text: allergens.replacingOccurrences(of: "en:", with: ""))
            }
        }
    }
}

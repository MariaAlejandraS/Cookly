import SwiftUI

/// Búsqueda en Open Food Facts. La validación no usa la pantalla de error.
struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: CooklyTheme.space8) {
                if let validation = viewModel.validationMessage {
                    Text(validation)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(CooklyTheme.warning)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(CooklyTheme.space12)
                        .background(CooklyTheme.warningSoft, in: RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
                        .padding(.horizontal, CooklyTheme.space16)
                }
                results
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .cooklyScreen()
            .navigationTitle("Buscar alimentos")
            .searchable(text: $viewModel.query, prompt: "Nombre o código de barras")
            .onSubmit(of: .search) { viewModel.search() }
            .navigationDestination(for: OFFProduct.self) { product in
                ProductDetailView(product: product)
            }
        }
    }

    @ViewBuilder
    private var results: some View {
        if viewModel.isLoading {
            ScrollView {
                VStack(spacing: CooklyTheme.space12) {
                    ForEach(0..<5, id: \.self) { _ in
                        SearchSkeletonRow()
                    }
                }
                .padding(CooklyTheme.space16)
            }
        } else if let error = viewModel.errorMessage {
            ScrollView {
                IllustratedEmpty(
                    symbol: "wifi.slash",
                    title: "Algo salió mal",
                    message: error,
                    primaryTitle: "Reintentar",
                    primaryAction: { viewModel.search() }
                )
            }
        } else if viewModel.results.isEmpty {
            ScrollView {
                IllustratedEmpty(
                    symbol: "magnifyingglass",
                    title: viewModel.hasSearched ? "Sin resultados" : "Busca un alimento",
                    message: viewModel.hasSearched
                        ? "Prueba con otro nombre o con el código de barras."
                        : "Escribe un nombre o un código de barras y toca Buscar."
                )
            }
        } else {
            List(viewModel.results) { product in
                NavigationLink(value: product) {
                    SearchResultRow(product: product)
                }
                .buttonStyle(.plain)
                .cooklyListRow()
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}

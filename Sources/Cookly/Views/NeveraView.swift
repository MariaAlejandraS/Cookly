import SwiftUI

/// Nevera: héroe, filtros con @Binding, tarjetas y botón flotante.
struct NeveraView: View {
    var onSearch: () -> Void = {}
    @StateObject private var viewModel = NeveraViewModel()
    @AppStorage("userName") private var userName = ""
    @State private var showAdd = false
    @State private var productToEdit: Product?
    @State private var productToDelete: Product?
    @State private var showSavedToast = false
    @State private var savedCount = 0
    @State private var fabTaps = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                productList
                addButton
            }
            .cooklyScreen()
            .navigationTitle("Nevera")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Buscar en mi nevera")
            .sheet(isPresented: $showAdd, onDismiss: { viewModel.load() }) {
                AddProductView(viewModel: AddProductViewModel(), onSaved: markSaved)
            }
            .sheet(item: $productToEdit, onDismiss: { viewModel.load() }) { product in
                AddProductView(viewModel: AddProductViewModel(product: product))
            }
            .confirmationDialog("¿Eliminar este producto?",
                                isPresented: Binding(get: { productToDelete != nil },
                                                     set: { if !$0 { productToDelete = nil } }),
                                titleVisibility: .visible) {
                Button("Eliminar", role: .destructive) {
                    if let product = productToDelete {
                        withAnimation(.snappy) { viewModel.delete(product) }
                    }
                    productToDelete = nil
                }
            } message: {
                Text(productToDelete?.name ?? "")
            }
            .toast(isPresented: $showSavedToast, message: "Alimento agregado a tu nevera", bottom: 108)
            .sensoryFeedback(.success, trigger: savedCount)
            .sensoryFeedback(.impact(weight: .medium), trigger: fabTaps)
        }
    }

    private var productList: some View {
        Group {
            if viewModel.products.isEmpty {
                ScrollView {
                    VStack(spacing: CooklyTheme.space16) {
                        hero
                        IllustratedEmpty(
                            symbol: "refrigerator.fill",
                            title: "Tu nevera está vacía",
                            message: "Agrega un alimento o búscalo por nombre.",
                            primaryTitle: "Agregar producto",
                            primaryAction: { showAdd = true },
                            secondaryTitle: "Buscar producto",
                            secondaryAction: onSearch
                        )
                    }
                    .padding(CooklyTheme.space16)
                }
            } else {
                filledList
            }
        }
    }

    private var filledList: some View {
        List {
            hero.cooklyListRow()
            FilterBar(selection: $viewModel.filter).cooklyListRow()
            if viewModel.visibleProducts.isEmpty {
                Text("Nada coincide con la búsqueda o el filtro.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .cooklyListRow()
            } else {
                ForEach(viewModel.visibleProducts) { product in
                    ProductRow(product: product)
                        .contentShape(Rectangle())
                        .onTapGesture { productToEdit = product }
                        .swipeActions {
                            Button(role: .destructive) { productToDelete = product } label: {
                                Label("Eliminar", systemImage: "trash")
                            }
                        }
                        .cooklyListRow()
                }
            }
            Color.clear.frame(height: 72).cooklyListRow()
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space16) {
            Text("Hola, \(userName)")
                .font(CooklyTheme.rounded(.title, weight: .bold))
                .foregroundStyle(CooklyTheme.onGradient)
            HStack {
                stat(viewModel.products.count, "Total")
                stat(dueSoon, "Por vencer")
                stat(viewModel.expiredCount, "Vencidos")
            }
        }
        .padding(CooklyTheme.space16)
        .background(CooklyTheme.brandGradient, in: RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous))
        .cooklyShadow()
    }

    private func stat(_ value: Int, _ title: String) -> some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(CooklyTheme.rounded(.title2, weight: .bold))
                .foregroundStyle(CooklyTheme.onGradient)
                .contentTransition(.numericText(countsDown: false))
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CooklyTheme.onGradient)
        }
        .frame(maxWidth: .infinity, minHeight: 44)
    }

    private var dueSoon: Int {
        viewModel.products.filter { $0.status == .soon || $0.status == .warning }.count
    }

    private var addButton: some View {
        Button {
            fabTaps += 1
            showAdd = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.weight(.bold))
                .foregroundStyle(CooklyTheme.onGradient)
                .frame(width: 60, height: 60)
                .background(CooklyTheme.brandGradient, in: Circle())
                .cooklyShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Agregar producto")
        .padding(CooklyTheme.space24)
    }

    private func markSaved() {
        savedCount += 1
        showSavedToast = true
    }
}

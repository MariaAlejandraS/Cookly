import Combine
import Foundation
import SwiftUI

/// ViewModel de la pantalla Nevera.
/// ObservableObject + @Published equivale a ViewModel + StateFlow en Android:
/// cuando `products` cambia, SwiftUI vuelve a dibujar las vistas que lo leen.
@MainActor
final class NeveraViewModel: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published var searchText = ""
    @Published var filter: StatusFilter = .all

    private let repository: any LocalStore
    private var changesCancellable: AnyCancellable?

    enum StatusFilter: String, CaseIterable, Identifiable {
        case all = "Todos"
        case soon = "Por vencer"
        case expired = "Vencidos"
        var id: String { rawValue }
    }

    init(repository: (any LocalStore)? = nil) {
        let store = repository ?? PersistenceFactory.make()
        self.repository = store
        changesCancellable = nil
        load()
        // El publisher refresca la lista aunque esta pestaña no vuelva a .onAppear.
        changesCancellable = store.changes.sink { [weak self] _ in
            Task { @MainActor in
                withAnimation(.snappy) { self?.load() }
            }
        }
    }

    func load() {
        products = repository.fetchProducts()
    }

    /// Lista que ve la pantalla: aplica búsqueda y filtro.
    var visibleProducts: [Product] {
        products.filter { product in
            let matchesText = searchText.isEmpty || product.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter: Bool
            switch filter {
            case .all: matchesFilter = true
            case .soon: matchesFilter = product.status == .soon || product.status == .warning
            case .expired: matchesFilter = product.status == .expired
            }
            return matchesText && matchesFilter
        }
    }

    var expiredCount: Int { products.filter { $0.status == .expired }.count }
    var soonCount: Int { products.filter { $0.status == .soon }.count }

    func delete(_ product: Product) {
        repository.delete(product)
        load()
    }
}

import Combine
import Foundation

/// ViewModel de la pantalla Buscar alimentos (RED).
/// Maneja los tres estados típicos de una petición: cargando, éxito y error.
@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query = ""
    @Published private(set) var results: [OFFProduct] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    /// Validación local (texto corto). No es un fallo de red.
    @Published private(set) var validationMessage: String?
    @Published private(set) var hasSearched = false

    private let api: FoodAPIService
    private var currentTask: Task<Void, Never>?
    /// Solo la búsqueda con este id puede escribir resultados, error o isLoading.
    private var latestSearchID = UUID()

    init(api: FoodAPIService? = nil) {
        self.api = api ?? .shared
    }

    func search() {
        let text = query.trimmingCharacters(in: .whitespaces)
        guard text.count >= 2 else {
            currentTask?.cancel()
            validationMessage = "Escribe al menos 2 letras."
            errorMessage = nil
            isLoading = false
            return
        }
        validationMessage = nil
        currentTask?.cancel()
        let searchID = UUID()
        latestSearchID = searchID
        currentTask = Task { @MainActor [weak self] in
            guard let self else { return }
            guard self.latestSearchID == searchID else { return }
            self.isLoading = true
            self.errorMessage = nil
            do {
                let found: [OFFProduct]
                // Si el texto son solo dígitos, se trata como código de barras.
                if text.allSatisfy(\.isNumber) {
                    found = [try await self.api.fetchProduct(barcode: text)]
                } else {
                    found = try await self.api.searchProducts(query: text)
                }
                guard self.latestSearchID == searchID else { return }
                self.results = found
                self.hasSearched = true
                self.isLoading = false
            } catch is CancellationError {
                return
            } catch let urlError as URLError where urlError.code == .cancelled {
                return
            } catch {
                guard self.latestSearchID == searchID else { return }
                self.results = []
                self.hasSearched = true
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

/// ViewModel del detalle de un producto de la API.
@MainActor
final class ProductDetailViewModel: ObservableObject {
    @Published private(set) var product: OFFProduct
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let api: FoodAPIService

    init(product: OFFProduct, api: FoodAPIService? = nil) {
        self.product = product
        self.api = api ?? .shared
    }

    /// Pide el detalle completo por código de barras (segunda llamada a la API).
    func loadDetail() async {
        isLoading = true
        errorMessage = nil
        do {
            product = try await api.fetchProduct(barcode: product.code)
            isLoading = false
        } catch is CancellationError {
            isLoading = false
        } catch let urlError as URLError where urlError.code == .cancelled {
            isLoading = false
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            isLoading = false
        }
    }
}

import Combine
import Foundation

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

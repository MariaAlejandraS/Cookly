import Combine
import Foundation

enum ScanState: Equatable {
    case idle
    case loading
    case added(Product)
    case needsDetails(OFFProduct)
    case notFound(String)
    case failed(String)
}

/// Lector de códigos: consulta Open Food Facts y, si hay nombre, lo guarda en la nevera.
@MainActor
final class ScanViewModel: ObservableObject {
    @Published private(set) var state: ScanState = .idle
    @Published private(set) var generation = UUID()
    @Published private(set) var scannedProduct: OFFProduct?

    let ownerId: UUID
    private let store: any LocalStore
    private let api: FoodAPIService
    private var lastCode: String?
    private var lastAccepted: (code: String, at: Date)?
    private var changesCancellable: AnyCancellable?

    init(ownerId: UUID, store: (any LocalStore)? = nil, api: FoodAPIService? = nil) {
        self.ownerId = ownerId
        let resolved = store ?? PersistenceFactory.make()
        self.store = resolved
        self.api = api ?? .shared
        changesCancellable = resolved.changes.sink { [weak self] _ in
            Task { @MainActor in self?.refreshAdded() }
        }
    }

    func handle(code: String) {
        guard state != .loading else { return }
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        if let last = lastAccepted, last.code == trimmed, Date().timeIntervalSince(last.at) < 3 {
            return
        }
        lastCode = trimmed
        state = .loading
        Task { await lookup(trimmed) }
    }

    func undo() {
        guard case .added(let product) = state,
              let owner = SessionManager.shared?.currentUser?.id else { return }
        store.delete(product, ownerId: owner)
    }

    func rescan() {
        state = .idle
        generation = UUID()
    }

    func retry() {
        guard let lastCode else { return }
        handle(code: lastCode)
    }

    private func lookup(_ code: String) async {
        do {
            let product = try await api.fetchProduct(barcode: code)
            guard !Task.isCancelled else { return }
            scannedProduct = product
            guard let rawName = product.usableName else {
                state = .needsDetails(product)
                return
            }
            let category = FoodCategory.from(offTags: product.categoriesTags ?? [])
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: .now)
            let expiration = calendar.date(byAdding: .day, value: category.minDays, to: today) ?? today
            guard let owner = SessionManager.shared?.currentUser?.id else {
                state = .failed("Inicia sesión para guardar.")
                return
            }
            let saved = Product(
                name: rawName,
                category: category,
                quantity: 1,
                expirationDate: expiration,
                barcode: code,
                imageURL: product.imageURL,
                ownerId: owner
            )
            store.insert(saved)
            lastAccepted = (code, Date())
            state = .added(saved)
        } catch let error as APIError {
            if case .notFound = error {
                state = .notFound(code)
            } else {
                state = .failed(error.localizedDescription)
            }
        } catch {
            state = .failed((error as? LocalizedError)?.errorDescription ?? error.localizedDescription)
        }
    }

    private func refreshAdded() {
        guard case .added(let product) = state else { return }
        let owner = SessionManager.shared?.currentUser?.id ?? ownerId
        if let fresh = store.fetchProducts(ownerId: owner).first(where: { $0.id == product.id }) {
            state = .added(fresh)
        }
    }
}

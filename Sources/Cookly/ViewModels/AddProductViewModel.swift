import Combine
import Foundation

/// ViewModel del formulario Agregar / Editar producto.
/// Guarda el estado de cada campo del formulario y valida antes de guardar.
@MainActor
final class AddProductViewModel: ObservableObject {
    @Published var name = ""
    @Published var category: FoodCategory = .otros {
        didSet { if autoDate { applySuggestedDate() } }
    }
    @Published var quantity = 1
    @Published var expirationDate = Calendar.current.date(byAdding: .day, value: FoodCategory.otros.minDays, to: .now) ?? .now
    @Published var autoDate = true {
        didSet { if autoDate { applySuggestedDate() } }
    }
    @Published var isOpened = false
    @Published var errorMessage: String?

    private let repository: any LocalStore
    private let ownerId: UUID
    private(set) var editing: Product?
    private var barcode: String?
    private var imageURL: String?

    var isEditing: Bool { editing != nil }
    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    /// Si recibe un producto, el formulario queda en modo edición.
    init(product: Product? = nil, ownerId: UUID, barcode: String? = nil, repository: (any LocalStore)? = nil) {
        self.repository = repository ?? PersistenceFactory.make()
        self.ownerId = ownerId
        if let product {
            editing = product
            name = product.name
            category = product.category
            quantity = product.quantity
            expirationDate = product.expirationDate
            isOpened = product.isOpened
            autoDate = false
            self.barcode = product.barcode
            imageURL = product.imageURL
        } else {
            self.barcode = barcode
            applySuggestedDate()
        }
    }

    /// Modo "agregar desde la API": llena el formulario con lo que devolvió Open Food Facts.
    convenience init(from offProduct: OFFProduct, ownerId: UUID) {
        self.init(ownerId: ownerId)
        name = offProduct.usableName ?? ""
        barcode = offProduct.code
        imageURL = offProduct.imageURL
        category = FoodCategory.from(offTags: offProduct.categoriesTags ?? [])
        applySuggestedDate()
    }

    /// Hoy + el mínimo de la categoría (el extremo corto, por seguridad alimentaria).
    func applySuggestedDate() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        expirationDate = calendar.date(byAdding: .day, value: category.minDays, to: today) ?? today
    }

    /// Valida y guarda. Devuelve true si se guardó, para que la vista se cierre.
    func save() -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Escribe el nombre del producto."
            return false
        }
        guard quantity > 0 else {
            errorMessage = "La cantidad debe ser mayor que cero."
            return false
        }

        guard let owner = SessionManager.shared?.currentUser?.id else { return false }
        if var product = editing {
            guard product.ownerId == owner else { return false }
            product.name = trimmed
            product.category = category
            product.quantity = quantity
            product.expirationDate = expirationDate
            product.isOpened = isOpened
            repository.update(product, ownerId: owner)
        } else {
            repository.insert(Product(
                name: trimmed,
                category: category,
                quantity: quantity,
                expirationDate: expirationDate,
                isOpened: isOpened,
                barcode: barcode,
                imageURL: imageURL,
                ownerId: owner
            ))
        }
        return true
    }
}

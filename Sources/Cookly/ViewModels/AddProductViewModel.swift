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
    @Published var notes = ""
    @Published var errorMessage: String?

    private let repository: any LocalStore
    private(set) var editing: Product?
    private var barcode: String?
    private var imageURL: String?

    var isEditing: Bool { editing != nil }
    var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    /// Si recibe un producto, el formulario queda en modo edición.
    init(product: Product? = nil, repository: (any LocalStore)? = nil) {
        self.repository = repository ?? PersistenceFactory.make()
        if let p = product {
            editing = p
            name = p.name
            category = p.category
            quantity = p.quantity
            expirationDate = p.expirationDate
            isOpened = p.isOpened
            notes = p.notes
            autoDate = false
            barcode = p.barcode
            imageURL = p.imageURL
        } else {
            applySuggestedDate()
        }
    }

    /// Modo "agregar desde la API": llena el formulario con lo que devolvió Open Food Facts.
    convenience init(from offProduct: OFFProduct) {
        self.init()
        name = offProduct.displayName
        barcode = offProduct.code
        imageURL = offProduct.imageURL
        category = FoodCategory.from(offTags: offProduct.categoriesTags ?? [])
        applySuggestedDate()
    }

    /// Hoy + el mínimo de la categoría (el extremo corto, por seguridad alimentaria).
    func applySuggestedDate() {
        expirationDate = Calendar.current.date(byAdding: .day, value: category.minDays, to: .now) ?? .now
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

        if var p = editing {
            p.name = trimmed
            p.category = category
            p.quantity = quantity
            p.expirationDate = expirationDate
            p.isOpened = isOpened
            p.notes = notes
            repository.update(p)
        } else {
            repository.insert(Product(name: trimmed,
                                      category: category,
                                      quantity: quantity,
                                      expirationDate: expirationDate,
                                      isOpened: isOpened,
                                      notes: notes,
                                      barcode: barcode,
                                      imageURL: imageURL))
        }
        return true
    }
}

import Combine
import Foundation
import SwiftData

// Si este init lanza, PersistenceFactory abre JSONStore y la demo sigue.

@Model
final class ProductEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var categoryRaw: String
    var quantity: Int
    var expirationDate: Date
    var isOpened: Bool
    var notes: String
    var barcode: String?
    var imageURL: String?
    var createdAt: Date

    init(
        id: UUID,
        name: String,
        categoryRaw: String,
        quantity: Int,
        expirationDate: Date,
        isOpened: Bool,
        notes: String,
        barcode: String?,
        imageURL: String?,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.categoryRaw = categoryRaw
        self.quantity = quantity
        self.expirationDate = expirationDate
        self.isOpened = isOpened
        self.notes = notes
        self.barcode = barcode
        self.imageURL = imageURL
        self.createdAt = createdAt
    }
}

@Model
final class ReminderEntity {
    @Attribute(.unique) var id: UUID
    var title: String
    var date: Date
    var isDone: Bool

    init(id: UUID, title: String, date: Date, isDone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.isDone = isDone
    }
}

/// Un solo ModelContainer para toda la app. Los structs Product y Reminder no cambian:
/// aquí solo se copian desde y hacia las entidades.
@MainActor
final class SwiftDataStore: LocalStore {
    private let container: ModelContainer
    private let context: ModelContext
    private let changesSubject = PassthroughSubject<Void, Never>()

    var changes: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    /// El inicializador más simple de iOS 17. Sin CloudKit ni configuración extra.
    init() throws {
        let container = try ModelContainer(for: ProductEntity.self, ReminderEntity.self)
        self.container = container
        self.context = container.mainContext
    }

    // MARK: - Productos

    func fetchProducts() -> [Product] {
        let descriptor = FetchDescriptor<ProductEntity>(
            sortBy: [SortDescriptor(\.expirationDate, order: .forward)]
        )
        do {
            return try context.fetch(descriptor).map(product(from:))
        } catch {
            // Una lectura fallida devuelve vacío en pantalla, pero NO borra filas:
            // no hay un "guardar toda la lista" que pise la base.
            print("SwiftData no pudo leer productos: \(error.localizedDescription)")
            return []
        }
    }

    func insert(_ product: Product) {
        context.insert(entity(from: product))
        saveAndNotify()
    }

    func update(_ product: Product) {
        guard let entity = findProduct(id: product.id) else { return }
        entity.name = product.name
        entity.categoryRaw = product.category.rawValue
        entity.quantity = product.quantity
        entity.expirationDate = product.expirationDate
        entity.isOpened = product.isOpened
        entity.notes = product.notes
        entity.barcode = product.barcode
        entity.imageURL = product.imageURL
        entity.createdAt = product.createdAt
        saveAndNotify()
    }

    func delete(_ product: Product) {
        guard let entity = findProduct(id: product.id) else { return }
        context.delete(entity)
        saveAndNotify()
    }

    // MARK: - Recordatorios

    func fetchReminders() -> [Reminder] {
        let descriptor = FetchDescriptor<ReminderEntity>(
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        do {
            return try context.fetch(descriptor).map(reminder(from:))
        } catch {
            print("SwiftData no pudo leer recordatorios: \(error.localizedDescription)")
            return []
        }
    }

    func insert(_ reminder: Reminder) {
        context.insert(entity(from: reminder))
        saveAndNotify()
    }

    func update(_ reminder: Reminder) {
        guard let entity = findReminder(id: reminder.id) else { return }
        entity.title = reminder.title
        entity.date = reminder.date
        entity.isDone = reminder.isDone
        saveAndNotify()
    }

    func delete(_ reminder: Reminder) {
        guard let entity = findReminder(id: reminder.id) else { return }
        context.delete(entity)
        saveAndNotify()
    }

    // MARK: - Mapeo y guardado

    private func saveAndNotify() {
        do {
            try context.save()
            changesSubject.send(())
        } catch {
            context.rollback()
            print("SwiftData no pudo guardar: \(error.localizedDescription)")
        }
    }

    /// Sin #Predicate: la nevera es pequeña y se busca el id en memoria.
    private func findProduct(id: UUID) -> ProductEntity? {
        let descriptor = FetchDescriptor<ProductEntity>()
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.first { $0.id == id }
    }

    private func findReminder(id: UUID) -> ReminderEntity? {
        let descriptor = FetchDescriptor<ReminderEntity>()
        let rows = (try? context.fetch(descriptor)) ?? []
        return rows.first { $0.id == id }
    }

    private func product(from entity: ProductEntity) -> Product {
        Product(
            id: entity.id,
            name: entity.name,
            category: FoodCategory(rawValue: entity.categoryRaw) ?? .otros,
            quantity: entity.quantity,
            expirationDate: entity.expirationDate,
            isOpened: entity.isOpened,
            notes: entity.notes,
            barcode: entity.barcode,
            imageURL: entity.imageURL,
            createdAt: entity.createdAt
        )
    }

    private func entity(from product: Product) -> ProductEntity {
        ProductEntity(
            id: product.id,
            name: product.name,
            categoryRaw: product.category.rawValue,
            quantity: product.quantity,
            expirationDate: product.expirationDate,
            isOpened: product.isOpened,
            notes: product.notes,
            barcode: product.barcode,
            imageURL: product.imageURL,
            createdAt: product.createdAt
        )
    }

    private func reminder(from entity: ReminderEntity) -> Reminder {
        Reminder(id: entity.id, title: entity.title, date: entity.date, isDone: entity.isDone)
    }

    private func entity(from reminder: Reminder) -> ReminderEntity {
        ReminderEntity(id: reminder.id, title: reminder.title, date: reminder.date, isDone: reminder.isDone)
    }
}

import Combine
import Foundation

/// Persistencia en JSON (la implementación que antes se llamaba LocalRepository).
/// Sigue siendo el plan B si SwiftData no abre en el laboratorio.
/// Un decode fallido NO sustituye el archivo por una lista vacía: lo mueve a `.bak`
/// y, si ni siquiera puede moverlo, se niega a escribir.
@MainActor
final class JSONStore: LocalStore {
    private var products: [Product] = []
    private var reminders: [Reminder] = []
    private var users: [User] = []
    private var canWriteProducts = true
    private var canWriteReminders = true
    private var canWriteUsers = true

    private let productsURL: URL
    private let remindersURL: URL
    private let usersURL: URL
    private let changesSubject = PassthroughSubject<Void, Never>()

    var changes: AnyPublisher<Void, Never> {
        changesSubject.eraseToAnyPublisher()
    }

    init(directory: URL? = nil) {
        let folder = directory ?? FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        productsURL = folder.appendingPathComponent("products.json")
        remindersURL = folder.appendingPathComponent("reminders.json")
        usersURL = folder.appendingPathComponent("users.json")

        let loadedProducts = Self.loadList(Product.self, from: productsURL)
        let loadedReminders = Self.loadList(Reminder.self, from: remindersURL)
        let loadedUsers = Self.loadList(User.self, from: usersURL)
        products = loadedProducts.items
        reminders = loadedReminders.items
        users = loadedUsers.items
        canWriteProducts = loadedProducts.allowWrite
        canWriteReminders = loadedReminders.allowWrite
        canWriteUsers = loadedUsers.allowWrite
    }

    // MARK: - Productos

    func fetchProducts() -> [Product] {
        products.sorted { $0.expirationDate < $1.expirationDate }
    }

    func fetchProducts(ownerId: UUID) -> [Product] {
        guard ownsAccount(ownerId) else { return [] }
        return fetchProducts().filter { $0.ownerId == ownerId }
    }

    func insert(_ product: Product) {
        guard ownsAccount(product.ownerId) else { return }
        products.append(product)
        guard write(products, to: productsURL, allowed: canWriteProducts) else {
            products.removeAll { $0.id == product.id }
            return
        }
        changesSubject.send(())
    }

    func update(_ product: Product, ownerId: UUID) {
        guard let index = products.firstIndex(where: { $0.id == product.id && $0.ownerId == ownerId }) else { return }
        let previous = products[index]
        var stored = product
        stored.ownerId = ownerId
        products[index] = stored
        guard write(products, to: productsURL, allowed: canWriteProducts) else {
            products[index] = previous
            return
        }
        changesSubject.send(())
    }

    func delete(_ product: Product, ownerId: UUID) {
        guard let previous = products.first(where: { $0.id == product.id && $0.ownerId == ownerId }) else { return }
        products.removeAll { $0.id == product.id }
        guard write(products, to: productsURL, allowed: canWriteProducts) else {
            products.append(previous)
            return
        }
        changesSubject.send(())
    }

    // MARK: - Recordatorios

    func fetchReminders() -> [Reminder] {
        reminders.sorted { $0.date < $1.date }
    }

    func fetchReminders(ownerId: UUID) -> [Reminder] {
        guard ownsAccount(ownerId) else { return [] }
        return fetchReminders().filter { $0.ownerId == ownerId }
    }

    func insert(_ reminder: Reminder) {
        guard ownsAccount(reminder.ownerId) else { return }
        reminders.append(reminder)
        guard write(reminders, to: remindersURL, allowed: canWriteReminders) else {
            reminders.removeAll { $0.id == reminder.id }
            return
        }
        changesSubject.send(())
    }

    func update(_ reminder: Reminder, ownerId: UUID) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id && $0.ownerId == ownerId }) else { return }
        let previous = reminders[index]
        var stored = reminder
        stored.ownerId = ownerId
        reminders[index] = stored
        guard write(reminders, to: remindersURL, allowed: canWriteReminders) else {
            reminders[index] = previous
            return
        }
        changesSubject.send(())
    }

    func delete(_ reminder: Reminder, ownerId: UUID) {
        guard let previous = reminders.first(where: { $0.id == reminder.id && $0.ownerId == ownerId }) else { return }
        reminders.removeAll { $0.id == reminder.id }
        guard write(reminders, to: remindersURL, allowed: canWriteReminders) else {
            reminders.append(previous)
            return
        }
        changesSubject.send(())
    }

    // MARK: - Cuentas

    func fetchUsers() -> [User] {
        users.sorted { $0.createdAt < $1.createdAt }
    }

    func insert(_ user: User) {
        users.append(user)
        guard write(users, to: usersURL, allowed: canWriteUsers) else {
            users.removeAll { $0.id == user.id }
            return
        }
        changesSubject.send(())
    }

    func update(_ user: User) {
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        let previous = users[index]
        users[index] = user
        guard write(users, to: usersURL, allowed: canWriteUsers) else {
            users[index] = previous
            return
        }
        changesSubject.send(())
    }

    private func ownsAccount(_ ownerId: UUID) -> Bool {
        users.contains { $0.id == ownerId }
    }

    // MARK: - Archivos

    private func write<T: Encodable>(_ value: T, to url: URL, allowed: Bool) -> Bool {
        guard allowed else {
            print("No se sobrescribe \(url.lastPathComponent): la lectura falló y no hubo respaldo.")
            return false
        }
        do {
            let data = try JSONEncoder().encode(value)
            try data.write(to: url, options: .atomic)
            return true
        } catch {
            print("Error guardando \(url.lastPathComponent): \(error.localizedDescription)")
            return false
        }
    }

    /// Archivo ausente → lista vacía y se puede escribir.
    /// Archivo ilegible → se mueve a `.bak` (no se borra) y solo entonces se permite un archivo nuevo.
    private static func loadList<Element: Decodable>(_: Element.Type, from url: URL) -> (items: [Element], allowWrite: Bool) {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: url.path) else {
            return ([], true)
        }
        guard let data = try? Data(contentsOf: url) else {
            print("No se pudo leer \(url.lastPathComponent).")
            return ([], backup(url))
        }
        do {
            let items = try JSONDecoder().decode([Element].self, from: data)
            return (items, true)
        } catch {
            print("JSON dañado en \(url.lastPathComponent): \(error.localizedDescription).")
            return ([], backup(url))
        }
    }

    /// Mueve el archivo dañado a `nombre.bak`. Devuelve false si el original sigue en su sitio.
    private static func backup(_ url: URL) -> Bool {
        let fileManager = FileManager.default
        let backupURL = url.deletingLastPathComponent().appendingPathComponent(url.lastPathComponent + ".bak")
        do {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.moveItem(at: url, to: backupURL)
            print("Respaldo conservado en \(backupURL.lastPathComponent). El original no se pisó con una lista vacía.")
            return true
        } catch {
            print("No se pudo respaldar \(url.lastPathComponent): \(error.localizedDescription). No se sobrescribirá.")
            return false
        }
    }
}

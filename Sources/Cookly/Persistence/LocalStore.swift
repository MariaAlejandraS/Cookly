import Combine
import Foundation

/// Contrato de persistencia. Los ViewModel dependen de este protocolo,
/// no de JSON ni de SwiftData.
/// Los ocho métodos son los que tenía LocalRepository; `changes` avisa a las pestañas.
@MainActor
protocol LocalStore: AnyObject {
    /// Se emite después de un insert, update o delete guardado.
    var changes: AnyPublisher<Void, Never> { get }

    func fetchProducts() -> [Product]
    func insert(_ product: Product)
    func update(_ product: Product)
    func delete(_ product: Product)

    func fetchReminders() -> [Reminder]
    func insert(_ reminder: Reminder)
    func update(_ reminder: Reminder)
    func delete(_ reminder: Reminder)
}

import Foundation

/// Una sola instancia para todas las pestañas. No usa `static let` con init:
/// ese patrón falla si Xcode trae Default Actor Isolation = MainActor.
@MainActor
enum PersistenceFactory {
    private static var cached: (any LocalStore)?
    private static var cachedName = "JSON (respaldo)"

    static var shared: any LocalStore { make() }

    /// "SwiftData" o "JSON (respaldo)", según lo que sí abrió.
    static var activeName: String {
        _ = make()
        return cachedName
    }

    static func make() -> any LocalStore {
        if let cached { return cached }
        let opened = open()
        cached = opened.store
        cachedName = opened.name
        return opened.store
    }

    private static func open() -> (store: any LocalStore, name: String) {
        do {
            return (try SwiftDataStore(), "SwiftData")
        } catch {
            print("AVISO Cookly: SwiftData no abrió (\(error.localizedDescription)). Almacenamiento activo: JSON (respaldo).")
            return (JSONStore(), "JSON (respaldo)")
        }
    }
}

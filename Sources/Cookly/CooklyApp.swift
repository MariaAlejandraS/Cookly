import SwiftUI

/// Punto de entrada de la app (equivale a MainActivity en Android).
/// La base la crea PersistenceFactory (SwiftData, o JSON si se cambia esa línea).
/// No se usa .modelContainer aquí: el store es el único dueño del ModelContainer.
@main
struct CooklyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

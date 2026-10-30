import Foundation

/// Recordatorio de comida guardado localmente (equivale a la tabla `reminders` de Room).
struct Reminder: Identifiable, Codable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var isDone: Bool = false
}

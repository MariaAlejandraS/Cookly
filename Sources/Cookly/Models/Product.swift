import Foundation
import SwiftUI

/// Producto de la nevera (equivale a la entidad Product de Room).
/// Codable permite convertirlo a JSON para guardarlo en el dispositivo;
/// Identifiable permite usarlo en List/ForEach y en .sheet(item:).
struct Product: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var category: FoodCategory
    var quantity: Int = 1
    var expirationDate: Date
    var isOpened: Bool = false
    var notes: String = ""
    var barcode: String?      // si vino de la API Open Food Facts
    var imageURL: String?
    var createdAt = Date.now

    /// Días que faltan para vencer, contando días de calendario (no trunca horas).
    var daysLeft: Int {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let end = cal.startOfDay(for: expirationDate)
        return cal.dateComponents([.day], from: start, to: end).day ?? 0
    }

    /// Usa los "días de aviso" que el usuario elige en Perfil (por defecto 3).
    var status: ExpiryStatus {
        let saved = UserDefaults.standard.integer(forKey: "warningDays")
        let warn = saved > 0 ? saved : 3
        let days = daysLeft
        if days < 0 { return .expired }
        if days < warn { return .soon }
        if days < 7 { return .warning }
        return .fresh
    }
}

enum ExpiryStatus {
    case expired, soon, warning, fresh

    var label: String {
        switch self {
        case .expired: return "Vencido"
        case .soon: return "Vence pronto"
        case .warning: return "Esta semana"
        case .fresh: return "Fresco"
        }
    }

    var color: Color {
        switch self {
        case .expired: return .red
        case .soon: return .orange
        case .warning: return .yellow
        case .fresh: return .green
        }
    }
}

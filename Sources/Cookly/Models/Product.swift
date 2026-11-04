import Foundation
import SwiftUI

/// Producto de la nevera (equivale a la entidad Product de Room).
/// Codable permite convertirlo a JSON para guardarlo en el dispositivo;
/// Identifiable permite usarlo en List/ForEach y en .sheet(item:).
struct Product: Identifiable, Hashable {
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
    /// Cuenta dueña. Los JSON viejos, sin este campo, no se mezclan con ninguna sesión.
    var ownerId: UUID = User.unassignedOwner

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

extension Product: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, category, quantity, expirationDate, isOpened, notes, barcode, imageURL, createdAt, ownerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(FoodCategory.self, forKey: .category)
        quantity = try container.decode(Int.self, forKey: .quantity)
        expirationDate = try container.decode(Date.self, forKey: .expirationDate)
        isOpened = try container.decode(Bool.self, forKey: .isOpened)
        notes = try container.decode(String.self, forKey: .notes)
        barcode = try container.decodeIfPresent(String.self, forKey: .barcode)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        ownerId = try container.decodeIfPresent(UUID.self, forKey: .ownerId) ?? User.unassignedOwner
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(expirationDate, forKey: .expirationDate)
        try container.encode(isOpened, forKey: .isOpened)
        try container.encode(notes, forKey: .notes)
        try container.encodeIfPresent(barcode, forKey: .barcode)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(ownerId, forKey: .ownerId)
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

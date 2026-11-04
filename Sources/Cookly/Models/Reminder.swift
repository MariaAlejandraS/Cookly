import Foundation

/// Recordatorio de comida guardado localmente (equivale a la tabla `reminders` de Room).
/// `weekdays` vacío significa una sola vez. 1 = lunes … 7 = domingo.
struct Reminder: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var date: Date
    var isDone: Bool = false
    var hour: Int = 8
    var minute: Int = 0
    var weekdays: [Int] = []
    var isEnabled: Bool = true
    var ownerId: UUID = User.unassignedOwner

    var repeats: Bool { !weekdays.isEmpty }

    /// Hora visible, por ejemplo "7:30 AM".
    var clockText: String {
        let calendar = Calendar.current
        let source: Date
        if repeats {
            var parts = DateComponents()
            parts.hour = hour
            parts.minute = minute
            source = calendar.date(from: parts) ?? date
        } else {
            source = date
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: source)
    }

    var repetitionLabel: String {
        let days = Set(weekdays)
        if days.isEmpty {
            let day = Calendar.current.component(.day, from: date)
            let month = Calendar.current.component(.month, from: date)
            let months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"]
            let name = months[max(0, min(month - 1, 11))]
            return "Una vez · \(day) \(name)"
        }
        if days == Set(1...7) { return "Todos los días" }
        if days == Set(1...5) { return "Lun a Vie" }
        if days == Set([6, 7]) { return "Fines de semana" }
        let names = [1: "Lun", 2: "Mar", 3: "Mié", 4: "Jue", 5: "Vie", 6: "Sáb", 7: "Dom"]
        return days.sorted().compactMap { names[$0] }.joined(separator: ", ")
    }

    /// La entidad SwiftData guarda los días como "1,2,3", no como arreglo.
    var weekdaysStorage: String {
        weekdays.sorted().map(String.init).joined(separator: ",")
    }

    static func weekdays(from storage: String) -> [Int] {
        storage.split(separator: ",").compactMap { Int($0.trimmingCharacters(in: .whitespaces)) }.filter { (1...7).contains($0) }
    }
}

extension Reminder: Codable {
    enum CodingKeys: String, CodingKey {
        case id, title, date, isDone, hour, minute, weekdays, isEnabled, ownerId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        isDone = try container.decode(Bool.self, forKey: .isDone)
        hour = try container.decodeIfPresent(Int.self, forKey: .hour) ?? 8
        minute = try container.decodeIfPresent(Int.self, forKey: .minute) ?? 0
        weekdays = try container.decodeIfPresent([Int].self, forKey: .weekdays) ?? []
        isEnabled = try container.decodeIfPresent(Bool.self, forKey: .isEnabled) ?? true
        ownerId = try container.decodeIfPresent(UUID.self, forKey: .ownerId) ?? User.unassignedOwner
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encode(isDone, forKey: .isDone)
        try container.encode(hour, forKey: .hour)
        try container.encode(minute, forKey: .minute)
        try container.encode(weekdays, forKey: .weekdays)
        try container.encode(isEnabled, forKey: .isEnabled)
        try container.encode(ownerId, forKey: .ownerId)
    }
}

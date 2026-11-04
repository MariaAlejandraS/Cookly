import Combine
import Foundation
import SwiftUI

struct MealSuggestion: Identifiable, Hashable {
    let title: String
    let hour: Int
    let minute: Int
    var id: String { title }

    var chip: String { "\(title) \(hour):\(String(format: "%02d", minute))" }

    static let breakfast = MealSuggestion(title: "Desayuno", hour: 7, minute: 30)
    static let lunch = MealSuggestion(title: "Almuerzo", hour: 12, minute: 30)
    static let dinner = MealSuggestion(title: "Cena", hour: 19, minute: 0)
    static let all = [breakfast, lunch, dinner]
}

/// ViewModel de Recordatorios de comidas.
@MainActor
final class RemindersViewModel: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []
    @Published var newTitle = ""
    @Published var newDate = Date.now.addingTimeInterval(3600)
    @Published var repeats = false
    @Published var weekdays: Set<Int> = []

    private let repository: any LocalStore
    private let ownerId: UUID
    private var changesCancellable: AnyCancellable?

    init(ownerId: UUID, repository: (any LocalStore)? = nil) {
        let store = repository ?? PersistenceFactory.make()
        self.repository = store
        self.ownerId = ownerId
        changesCancellable = nil
        load()
        changesCancellable = store.changes.sink { [weak self] _ in
            Task { @MainActor in
                withAnimation(.snappy) { self?.load() }
            }
        }
    }

    func load() {
        reminders = Self.sorted(repository.fetchReminders(ownerId: sessionOwner ?? ownerId))
    }

    var canAdd: Bool {
        let titleOK = !newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if repeats { return titleOK && !weekdays.isEmpty }
        return titleOK
    }

    func applySuggestion(_ suggestion: MealSuggestion) {
        newTitle = suggestion.title
        let calendar = Calendar.current
        var parts = calendar.dateComponents([.year, .month, .day], from: .now)
        parts.hour = suggestion.hour
        parts.minute = suggestion.minute
        var when = calendar.date(from: parts) ?? .now
        if !repeats, when <= .now {
            when = calendar.date(byAdding: .day, value: 1, to: when) ?? when
        }
        newDate = when
    }

    func toggleDay(_ day: Int) {
        if weekdays.contains(day) {
            weekdays.remove(day)
        } else {
            weekdays.insert(day)
        }
    }

    func setRepeats(_ value: Bool) {
        repeats = value
        if !value, newDate <= .now {
            newDate = .now.addingTimeInterval(3600)
        }
    }

    func add() {
        guard canAdd else { return }
        let calendar = Calendar.current
        let parts = calendar.dateComponents([.hour, .minute], from: newDate)
        guard let owner = sessionOwner else { return }
        let reminder = Reminder(
            title: newTitle.trimmingCharacters(in: .whitespacesAndNewlines),
            date: newDate,
            hour: parts.hour ?? 8,
            minute: parts.minute ?? 0,
            weekdays: repeats ? weekdays.sorted() : [],
            isEnabled: true,
            ownerId: owner
        )
        repository.insert(reminder)
        newTitle = ""
        newDate = Date.now.addingTimeInterval(3600)
        load()
    }

    func setEnabled(_ reminder: Reminder, _ enabled: Bool) {
        guard let owner = sessionOwner else { return }
        var updated = reminder
        updated.isEnabled = enabled
        repository.update(updated, ownerId: owner)
        load()
    }

    func delete(_ reminder: Reminder) {
        guard let owner = sessionOwner else { return }
        repository.delete(reminder, ownerId: owner)
        load()
    }

    private var sessionOwner: UUID? { SessionManager.shared?.currentUser?.id }

    /// Primero los que se repiten, por hora; después los de una sola vez, por fecha.
    private static func sorted(_ items: [Reminder]) -> [Reminder] {
        items.sorted { lhs, rhs in
            if lhs.repeats != rhs.repeats { return lhs.repeats }
            if lhs.repeats {
                if lhs.hour != rhs.hour { return lhs.hour < rhs.hour }
                return lhs.minute < rhs.minute
            }
            return lhs.date < rhs.date
        }
    }
}

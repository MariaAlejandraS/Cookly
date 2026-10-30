import Combine
import Foundation
import SwiftUI

/// ViewModel de Recordatorios de comidas.
@MainActor
final class RemindersViewModel: ObservableObject {
    @Published private(set) var reminders: [Reminder] = []
    @Published var newTitle = ""
    @Published var newDate = Date.now.addingTimeInterval(3600)
    @Published var showDone = true

    private let repository: any LocalStore
    private var changesCancellable: AnyCancellable?

    init(repository: (any LocalStore)? = nil) {
        let store = repository ?? PersistenceFactory.make()
        self.repository = store
        changesCancellable = nil
        load()
        changesCancellable = store.changes.sink { [weak self] _ in
            Task { @MainActor in
                withAnimation(.snappy) { self?.load() }
            }
        }
    }

    func load() {
        reminders = repository.fetchReminders()
    }

    var visibleReminders: [Reminder] {
        showDone ? reminders : reminders.filter { !$0.isDone }
    }

    var canAdd: Bool { !newTitle.trimmingCharacters(in: .whitespaces).isEmpty }

    func add() {
        guard canAdd else { return }
        repository.insert(Reminder(title: newTitle.trimmingCharacters(in: .whitespaces), date: newDate))
        newTitle = ""
        newDate = Date.now.addingTimeInterval(3600)
        load()
    }

    func toggle(_ reminder: Reminder) {
        var updated = reminder
        updated.isDone.toggle()
        repository.update(updated)
        load()
    }

    func delete(_ reminder: Reminder) {
        repository.delete(reminder)
        load()
    }
}

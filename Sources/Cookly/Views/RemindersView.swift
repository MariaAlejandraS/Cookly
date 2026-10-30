import SwiftUI

/// Recordatorios: chip de hoy, tarjetas y formulario en una tarjeta.
struct RemindersView: View {
    @StateObject private var viewModel = RemindersViewModel()

    var body: some View {
        NavigationStack {
            List {
                dateChip.cooklyListRow()
                form.cooklyListRow()
                Toggle("Mostrar completados", isOn: $viewModel.showDone)
                    .frame(minHeight: 44)
                    .cooklyListRow()
                if viewModel.visibleReminders.isEmpty {
                    Text(viewModel.reminders.isEmpty
                         ? "Aún no hay recordatorios."
                         : "No hay pendientes. Activa «Mostrar completados».")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .cooklyListRow()
                } else {
                    ForEach(viewModel.visibleReminders) { reminder in
                        ReminderRow(reminder: reminder) { viewModel.toggle(reminder) }
                            .swipeActions {
                                Button(role: .destructive) {
                                    withAnimation(.snappy) { viewModel.delete(reminder) }
                                } label: {
                                    Label("Eliminar", systemImage: "trash")
                                }
                            }
                            .cooklyListRow()
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .cooklyScreen()
            .navigationTitle("Recordatorios")
        }
    }

    private var dateChip: some View {
        Pill(text: Self.todayText, foreground: .white, background: CooklyTheme.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            SectionHeader(title: "Nuevo recordatorio", subtitle: "Planea desayuno, almuerzo o cena.")
            TextField("Ej. Desayuno", text: $viewModel.newTitle)
                .textInputAutocapitalization(.sentences)
                .cooklyField()
            DatePicker("Cuándo", selection: $viewModel.newDate, in: Date.now...)
                .frame(minHeight: 44)
            Button {
                withAnimation(.snappy) { viewModel.add() }
            } label: {
                Label("Agregar recordatorio", systemImage: "plus")
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.canAdd)
            .opacity(viewModel.canAdd ? 1 : 0.45)
        }
        .cardStyle()
    }

    private static var todayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "es_ES")
        formatter.setLocalizedDateFormatFromTemplate("EEEEdMMMM")
        let raw = formatter.string(from: .now)
        guard let first = raw.first else { return raw }
        return first.uppercased() + String(raw.dropFirst())
    }
}

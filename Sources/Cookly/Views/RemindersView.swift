import SwiftUI

/// Recordatorios: chips de comida, una vez o repetición, y tarjetas con hora.
struct RemindersView: View {
    @StateObject private var viewModel: RemindersViewModel

    init(ownerId: UUID) {
        _viewModel = StateObject(wrappedValue: RemindersViewModel(ownerId: ownerId))
    }

    var body: some View {
        NavigationStack {
            List {
                dateChip.cooklyListRow()
                form.cooklyListRow()
                if viewModel.reminders.isEmpty {
                    Text("Aún no hay recordatorios.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .cooklyListRow()
                } else {
                    ForEach(viewModel.reminders) { reminder in
                        ReminderRow(reminder: reminder) { enabled in
                            viewModel.setEnabled(reminder, enabled)
                        }
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: CooklyTheme.space8) {
                    ForEach(MealSuggestion.all) { suggestion in
                        Button(suggestion.chip) { viewModel.applySuggestion(suggestion) }
                            .buttonStyle(.borderless)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(viewModel.newTitle == suggestion.title ? CooklyTheme.onGradient : CooklyTheme.ink)
                            .padding(.horizontal, CooklyTheme.space12)
                            .frame(minHeight: 36)
                            .background(
                                viewModel.newTitle == suggestion.title ? AnyShapeStyle(CooklyTheme.brandGradient) : AnyShapeStyle(CooklyTheme.canvas),
                                in: Capsule()
                            )
                    }
                }
            }
            Picker("Frecuencia", selection: Binding(
                get: { viewModel.repeats },
                set: { viewModel.setRepeats($0) }
            )) {
                Text("Una vez").tag(false)
                Text("Se repite").tag(true)
            }
            .pickerStyle(.segmented)
            if viewModel.repeats {
                DatePicker("Hora", selection: $viewModel.newDate, displayedComponents: .hourAndMinute)
                    .frame(minHeight: 44)
                dayChips
                shortcuts
                if viewModel.weekdays.isEmpty && !viewModel.newTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Elige al menos un día.")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(CooklyTheme.danger)
                }
            } else {
                DatePicker(
                    "Fecha y hora",
                    selection: $viewModel.newDate,
                    in: Date.now...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .frame(minHeight: 44)
            }
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

    private var dayChips: some View {
        let days = [(1, "L", "Lunes"), (2, "M", "Martes"), (3, "X", "Miércoles"), (4, "J", "Jueves"), (5, "V", "Viernes"), (6, "S", "Sábado"), (7, "D", "Domingo")]
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
            ForEach(days, id: \.0) { day, letter, name in
                let selected = viewModel.weekdays.contains(day)
                Button {
                    viewModel.toggleDay(day)
                } label: {
                    Text(letter)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(selected ? CooklyTheme.onGradient : CooklyTheme.ink)
                        .frame(width: 36, height: 36)
                        .background(
                            selected ? AnyShapeStyle(CooklyTheme.brandGradient) : AnyShapeStyle(CooklyTheme.canvas),
                            in: Circle()
                        )
                }
                .buttonStyle(.borderless)
                .accessibilityLabel(name)
                .accessibilityAddTraits(selected ? .isSelected : AccessibilityTraits())
            }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var shortcuts: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: CooklyTheme.space8) {
                shortcut("Todos los días", days: Set(1...7))
                shortcut("Entre semana", days: Set(1...5))
                shortcut("Fines de semana", days: Set([6, 7]))
            }
        }
    }

    private func shortcut(_ title: String, days: Set<Int>) -> some View {
        let selected = viewModel.weekdays == days
        return Button(title) { viewModel.weekdays = days }
            .buttonStyle(.borderless)
            .font(.caption2.weight(.bold))
            .foregroundStyle(selected ? CooklyTheme.onGradient : CooklyTheme.ink)
            .padding(.horizontal, 8)
            .frame(minHeight: 32)
            .background(selected ? AnyShapeStyle(CooklyTheme.brandGradient) : AnyShapeStyle(CooklyTheme.canvas), in: Capsule())
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

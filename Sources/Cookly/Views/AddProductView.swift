import SwiftUI

/// Alta y edición. La cuadrícula elige la categoría; el Picker la muestra en menú.
struct AddProductView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: AddProductViewModel
    var onSaved: () -> Void = {}

    init(viewModel: AddProductViewModel, onSaved: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSaved = onSaved
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CooklyTheme.space16) {
                    productCard
                    dateCard
                    notesCard
                    adviceCard
                }
                .padding(CooklyTheme.space16)
            }
            .scrollDismissesKeyboard(.interactively)
            .cooklyScreen()
            .navigationTitle(viewModel.isEditing ? "Editar producto" : "Nuevo producto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                saveBar
            }
        }
    }

    private var productCard: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            TextField("Nombre (ej. Leche entera)", text: $viewModel.name)
                .textInputAutocapitalization(.sentences)
                .cooklyField()
            Picker("Categoría", selection: $viewModel.category) {
                ForEach(FoodCategory.allCases) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.menu)
            CategoryGrid(selection: $viewModel.category)
            Stepper("Cantidad: \(viewModel.quantity)", value: $viewModel.quantity, in: 1...99)
                .frame(minHeight: 44)
        }
        .cardStyle()
    }

    private var dateCard: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            SectionHeader(title: "Vencimiento")
            livePill
            Toggle("Sugerir fecha por categoría", isOn: $viewModel.autoDate)
            DatePicker("Vence el", selection: $viewModel.expirationDate,
                       in: Date.now.addingTimeInterval(-86400 * 30)...,
                       displayedComponents: .date)
                .disabled(viewModel.autoDate)
        }
        .cardStyle()
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            Toggle("Empaque abierto", isOn: $viewModel.isOpened)
            TextField("Notas (opcional)", text: $viewModel.notes, axis: .vertical)
                .lineLimit(2...4)
                .cooklyField()
        }
        .cardStyle()
    }

    private var adviceCard: some View {
        HStack(alignment: .top, spacing: CooklyTheme.space12) {
            IconTile(systemName: "info.circle.fill")
            Text("Recomendado: \(viewModel.category.minDays) a \(viewModel.category.maxDays) días en refrigeración. La fecha sugerida usa el mínimo; ajústala según el empaque.")
                .font(.subheadline)
                .foregroundStyle(CooklyTheme.ink)
        }
        .cardStyle()
    }

    private var saveBar: some View {
        VStack(spacing: CooklyTheme.space8) {
            if let error = viewModel.errorMessage {
                Text(error).font(.footnote.weight(.semibold)).foregroundStyle(CooklyTheme.danger)
            }
            Button("Guardar", action: commit)
                .buttonStyle(PrimaryButtonStyle())
                .disabled(!viewModel.canSave)
                .opacity(viewModel.canSave ? 1 : 0.45)
        }
        .padding(.horizontal, CooklyTheme.space16)
        .padding(.vertical, CooklyTheme.space12)
        .background(.ultraThinMaterial)
    }

    private var daysUntil: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: .now)
        let end = calendar.startOfDay(for: viewModel.expirationDate)
        return calendar.dateComponents([.day], from: start, to: end).day ?? 0
    }

    private func commit() {
        let creating = !viewModel.isEditing
        guard viewModel.save() else { return }
        if creating { onSaved() }
        dismiss()
    }

    private var livePill: some View {
        let days = daysUntil
        let text: String
        let foreground: Color
        let background: Color
        if days < 0 {
            text = "Venció hace \(-days) d"
            foreground = CooklyTheme.danger
            background = CooklyTheme.dangerSoft
        } else if days == 0 {
            text = "Vence hoy"
            foreground = CooklyTheme.danger
            background = CooklyTheme.dangerSoft
        } else if days == 1 {
            text = "Vence mañana"
            foreground = CooklyTheme.warning
            background = CooklyTheme.warningSoft
        } else {
            text = "Vence en \(days) días"
            foreground = CooklyTheme.success
            background = CooklyTheme.successSoft
        }
        return Pill(text: text, foreground: foreground, background: background)
    }
}

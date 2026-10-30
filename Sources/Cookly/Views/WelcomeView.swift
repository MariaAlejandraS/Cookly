import SwiftUI

/// Primera pantalla. El nombre se guarda en @AppStorage y abre las pestañas.
struct WelcomeView: View {
    @AppStorage("userName") private var userName = ""
    @State private var nameInput = ""
    @FocusState private var focused: Bool
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: CooklyTheme.space24) {
                header
                VStack(spacing: CooklyTheme.space12) {
                    BenefitRow(icon: "calendar", title: "Controla vencimientos", detail: "Ves qué se acaba primero.")
                    BenefitRow(icon: "magnifyingglass", title: "Busca productos reales", detail: "Nombre o código de barras.")
                    BenefitRow(icon: "fork.knife", title: "Planea tus comidas", detail: "Recordatorios junto a la nevera.")
                }
                TextField("¿Cómo te llamas?", text: $nameInput)
                    .textContentType(.givenName)
                    .focused($focused)
                    .submitLabel(.done)
                    .onSubmit(start)
                    .cooklyField()
                Button("Empezar", action: start)
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)
            }
            .padding(CooklyTheme.space24)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
        }
        .cooklyScreen()
        .onAppear {
            withAnimation(.easeOut(duration: 0.45)) { appeared = true }
            focused = true
        }
    }

    private var header: some View {
        VStack(spacing: CooklyTheme.space12) {
            Image(systemName: "refrigerator.fill")
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 88, height: 88)
                .background(CooklyTheme.primary, in: RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous))
                .padding(5)
                .background(CooklyTheme.surface, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .cooklyShadow()
                .accessibilityHidden(true)
            Text("COOKLY")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .tracking(2)
                .foregroundStyle(CooklyTheme.onGradient)
            Text("Tu nevera digital")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(CooklyTheme.onGradient.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CooklyTheme.space24)
        .background {
            RoundedRectangle(cornerRadius: CooklyTheme.radius24, style: .continuous)
                .fill(CooklyTheme.brandGradient)
        }
    }

    private func start() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        userName = trimmed
    }
}

private struct BenefitRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            IconTile(systemName: icon)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.semibold)).foregroundStyle(CooklyTheme.ink)
                Text(detail).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .cardStyle()
    }
}

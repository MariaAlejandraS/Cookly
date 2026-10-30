import SwiftUI

/// Perfil. El nombre se edita en un borrador: vaciar el campo no vuelve a la bienvenida.
struct ProfileView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("darkMode") private var darkMode = false
    @AppStorage("warningDays") private var warningDays = 3
    @Environment(\.colorScheme) private var colorScheme

    @State private var nameDraft: String
    @State private var nameError: String?
    @State private var allowNameCommit = true
    @FocusState private var nameFieldFocused: Bool
    @State private var showLogout = false

    init() {
        let stored = UserDefaults.standard.string(forKey: "userName") ?? ""
        _nameDraft = State(initialValue: stored)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CooklyTheme.space16) {
                    header
                    nameCard
                    preferences
                    aboutLink
                    logoutButton
                }
                .padding(CooklyTheme.space16)
            }
            .cooklyScreen()
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                guard !userName.isEmpty else { return }
                commitName()
            }
            .alert("¿Cerrar sesión?", isPresented: $showLogout) {
                Button("Cancelar", role: .cancel) {}
                Button("Cerrar sesión", role: .destructive) {
                    allowNameCommit = false
                    userName = ""
                }
            } message: {
                Text("Tus productos seguirán guardados en este dispositivo.")
            }
        }
    }

    private var header: some View {
        VStack(spacing: CooklyTheme.space12) {
            InitialsAvatar(name: userName, size: 96)
            Text(userName)
                .font(CooklyTheme.rounded(.title, weight: .bold))
                .foregroundStyle(CooklyTheme.ink)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CooklyTheme.space8)
    }

    private var nameCard: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space8) {
            Text("Tu nombre")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            TextField("Nombre", text: $nameDraft)
                .textContentType(.givenName)
                .submitLabel(.done)
                .focused($nameFieldFocused)
                .onSubmit(commitName)
                .onChange(of: nameFieldFocused) { _, focused in
                    if !focused { commitName() }
                }
                .cooklyField()
            if let nameError {
                Text(nameError)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(CooklyTheme.danger)
            }
        }
        .cardStyle()
    }

    private var preferences: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space12) {
            SectionHeader(title: "Preferencias")
            Toggle("Modo oscuro", isOn: $darkMode)
                .frame(minHeight: 44)
            Stepper("Avisarme \(warningDays) días antes", value: $warningDays, in: 1...7)
                .frame(minHeight: 44)
            Text("Tema actual: \(colorScheme == .dark ? "Oscuro" : "Claro")")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var aboutLink: some View {
        NavigationLink {
            AboutView()
        } label: {
            HStack(spacing: CooklyTheme.space12) {
                IconTile(systemName: "info.circle.fill")
                Text("Acerca de Cookly")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CooklyTheme.ink)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var logoutButton: some View {
        Button("Cerrar sesión") { showLogout = true }
            .buttonStyle(.plain)
            .font(CooklyTheme.rounded(.headline, weight: .semibold))
            .foregroundStyle(CooklyTheme.danger)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(CooklyTheme.dangerSoft, in: Capsule())
    }

    /// Guarda el nombre solo si quedó algo escrito. Borrar el campo no cierra la sesión.
    private func commitName() {
        guard allowNameCommit else { return }
        let trimmed = nameDraft.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            nameDraft = userName
            nameError = "El nombre no puede quedar vacío."
            return
        }
        nameError = nil
        userName = trimmed
        nameDraft = trimmed
    }
}

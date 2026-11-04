import SwiftUI

/// Inicio de sesión. Sin cuenta, empuja el registro.
struct LoginView: View {
    @EnvironmentObject private var session: SessionManager
    @StateObject private var model = AuthViewModel()
    @FocusState private var focus: AuthField?
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: CooklyTheme.space16) {
                    AuthHeader()
                    VStack(spacing: CooklyTheme.space12) {
                        BenefitRow(icon: "calendar", title: "Controla vencimientos", detail: "Ves qué se acaba primero.")
                        BenefitRow(icon: "barcode.viewfinder", title: "Escanea productos reales", detail: "Código de barras con la cámara.")
                        BenefitRow(icon: "fork.knife", title: "Planea tus comidas", detail: "Recordatorios junto a la nevera.")
                    }
                    VStack(alignment: .leading, spacing: CooklyTheme.space8) {
                        TextField("Usuario", text: $model.username)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($focus, equals: .username)
                            .submitLabel(.next)
                            .onSubmit { focus = .password }
                            .cooklyField()
                        AuthErrorText(message: model.usernameError)
                        SecretField(
                            prompt: "Contraseña",
                            text: $model.password,
                            focused: $focus,
                            field: .password,
                            submit: .done,
                            onSubmit: submit
                        )
                        AuthErrorText(message: model.loginError)
                    }
                    Button("Iniciar sesión", action: submit)
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!model.canLogin)
                        .opacity(model.canLogin ? 1 : 0.45)
                        .allowsHitTesting(!model.isBusy)
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("¿No tienes cuenta? Regístrate")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(CooklyTheme.brandForeground)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                }
                .padding(CooklyTheme.space24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 18)
            }
            .scrollDismissesKeyboard(.interactively)
            .cooklyScreen()
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.45)) { appeared = true }
                focus = .username
            }
            .onChange(of: model.username) { _, _ in
                model.usernameError = nil
                if !model.isLocked { model.loginError = nil }
                model.refreshLock(using: session)
                model.validate(showEmpty: false)
            }
            .onChange(of: model.password) { _, _ in
                if !model.isLocked { model.loginError = nil }
            }
            .onChange(of: session.formEpoch) { _, _ in
                model.reset()
            }
        }
    }

    private func submit() {
        focus = nil
        model.login(using: session)
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

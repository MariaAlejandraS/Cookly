import SwiftUI

/// Alta de cuenta. Si el registro sale bien, la sesión entra sola a Nevera.
struct RegisterView: View {
    @EnvironmentObject private var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    @StateObject private var model = AuthViewModel()
    @FocusState private var focus: AuthField?

    var body: some View {
        ScrollView {
            VStack(spacing: CooklyTheme.space16) {
                AuthHeader()
                VStack(alignment: .leading, spacing: CooklyTheme.space8) {
                    TextField("Nombre", text: $model.name)
                        .textContentType(.name)
                        .textInputAutocapitalization(.words)
                        .focused($focus, equals: .name)
                        .submitLabel(.next)
                        .onSubmit { focus = .username }
                        .cooklyField()
                    AuthErrorText(message: model.nameError)
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
                        isNew: true,
                        onSubmit: submit
                    )
                    Text(PasswordPolicy.hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    AuthErrorText(message: model.passwordError)
                }
                Button("Crear cuenta", action: submit)
                    .buttonStyle(PrimaryButtonStyle())
                    .disabled(!model.canRegister)
                    .opacity(model.canRegister ? 1 : 0.45)
                    .allowsHitTesting(!model.isBusy)
                Button("¿Ya tienes cuenta? Inicia sesión") { dismiss() }
                    .buttonStyle(.plain)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(CooklyTheme.brandForeground)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .padding(CooklyTheme.space24)
        }
        .scrollDismissesKeyboard(.interactively)
        .cooklyScreen()
        .navigationTitle("Registro")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { focus = .name }
        .onChange(of: model.name) { _, _ in model.validate(showEmpty: false, forRegister: true) }
        .onChange(of: model.username) { _, _ in
            model.usernameError = nil
            model.validate(showEmpty: false, forRegister: true)
        }
        .onChange(of: model.password) { _, _ in model.validate(showEmpty: false, forRegister: true) }
        .onChange(of: session.formEpoch) { _, _ in model.reset() }
    }

    private func submit() {
        focus = nil
        model.register(using: session)
    }
}

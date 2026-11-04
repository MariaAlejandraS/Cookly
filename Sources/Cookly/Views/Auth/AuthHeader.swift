import SwiftUI

/// Encabezado de acceso: el mismo bloque de COOKLY que abría la app.
struct AuthHeader: View {
    var body: some View {
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
}

struct SecretField: View {
    let prompt: String
    @Binding var text: String
    var focused: FocusState<AuthField?>.Binding
    let field: AuthField
    var submit: SubmitLabel
    var isNew = false
    var onSubmit: () -> Void
    @State private var visible = false

    var body: some View {
        HStack(spacing: CooklyTheme.space8) {
            Group {
                if visible {
                    TextField(prompt, text: $text)
                } else {
                    SecureField(prompt, text: $text)
                }
            }
            .textContentType(isNew ? .newPassword : .password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused(focused, equals: field)
            .submitLabel(submit)
            .onSubmit(onSubmit)
            Button {
                visible.toggle()
                focused.wrappedValue = field
            } label: {
                Image(systemName: visible ? "eye.slash" : "eye")
                    .foregroundStyle(CooklyTheme.brandForeground)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(visible ? "Ocultar contraseña" : "Mostrar contraseña")
        }
        .cooklyField()
    }
}

struct AuthErrorText: View {
    let message: String?

    var body: some View {
        if let message {
            Text(message)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(CooklyTheme.danger)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

import SwiftUI

/// Estado vacío con círculos concéntricos. Sin Canvas.
struct IllustratedEmpty: View {
    let symbol: String
    let title: String
    let message: String
    var primaryTitle: String? = nil
    var primaryAction: (() -> Void)? = nil
    var secondaryTitle: String? = nil
    var secondaryAction: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: CooklyTheme.space16) {
            ZStack {
                Circle().stroke(CooklyTheme.secondary.opacity(0.45), lineWidth: 10).frame(width: 132, height: 132)
                Circle().stroke(CooklyTheme.primary.opacity(0.7), lineWidth: 10).frame(width: 92, height: 92)
                Circle().fill(CooklyTheme.brandGradient).frame(width: 64, height: 64)
                Image(systemName: symbol)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(CooklyTheme.onGradient)
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(CooklyTheme.rounded(.title3, weight: .bold))
                .foregroundStyle(CooklyTheme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if let primaryTitle, let primaryAction {
                Button(primaryTitle, action: primaryAction).buttonStyle(PrimaryButtonStyle())
            }
            if let secondaryTitle, let secondaryAction {
                Button(secondaryTitle, action: secondaryAction).buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(CooklyTheme.space24)
        .frame(maxWidth: .infinity)
    }
}

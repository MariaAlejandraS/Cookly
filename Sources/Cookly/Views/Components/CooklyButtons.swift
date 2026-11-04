import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CooklyTheme.rounded(.headline, weight: .semibold))
            .foregroundStyle(CooklyTheme.onGradient)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(CooklyTheme.brandGradient, in: Capsule())
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(CooklyTheme.rounded(.headline, weight: .semibold))
            .foregroundStyle(CooklyTheme.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(CooklyTheme.surface, in: Capsule())
            .overlay(Capsule().stroke(CooklyTheme.primary, lineWidth: 1.5))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

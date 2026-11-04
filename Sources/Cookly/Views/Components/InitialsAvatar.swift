import SwiftUI

struct InitialsAvatar: View {
    let name: String
    var size: CGFloat = 56

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return String(parts.compactMap(\.first)).uppercased()
    }

    var body: some View {
        Text(initials.isEmpty ? "?" : initials)
            .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
            .foregroundStyle(CooklyTheme.onGradient)
            .frame(width: size, height: size)
            .background(CooklyTheme.brandGradient, in: Circle())
            .accessibilityHidden(true)
    }
}

import SwiftUI

/// Ícono sobre un cuadro redondeado tintado. El lado mínimo es 44 pt.
struct IconTile: View {
    let systemName: String
    var tint: Color = CooklyTheme.brandForeground
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.4, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: max(size, 44), height: max(size, 44))
            .background(tint.opacity(0.16), in: RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
            .accessibilityHidden(true)
    }
}

import SwiftUI

struct NutriScoreBadge: View {
    let grade: String

    private var fill: Color {
        switch grade.lowercased() {
        case "a": return CooklyTheme.success
        case "b": return CooklyTheme.brandForeground
        case "c": return CooklyTheme.warning
        default: return CooklyTheme.danger
        }
    }

    var body: some View {
        Text(grade.uppercased())
            .font(CooklyTheme.rounded(.headline, weight: .bold))
            .foregroundStyle(CooklyTheme.onFill)
            .frame(width: 36, height: 36)
            .background(fill, in: RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
            .accessibilityLabel("Nutri-Score \(grade.uppercased())")
    }
}

import SwiftUI

struct Pill: View {
    let text: String
    let foreground: Color
    let background: Color

    var body: some View {
        Text(text)
            .font(CooklyTheme.rounded(.caption, weight: .bold))
            .foregroundStyle(foreground)
            .padding(.horizontal, CooklyTheme.space12)
            .padding(.vertical, CooklyTheme.space8)
            .background(background, in: Capsule())
    }
}

/// Pastilla de vencimiento: hoy rojo, mañana ámbar, el resto verde.
struct ExpiryBadge: View {
    let status: ExpiryStatus
    let daysLeft: Int

    var body: some View {
        let look = Self.look(daysLeft)
        Pill(text: look.text, foreground: look.foreground, background: look.background)
            .accessibilityLabel("\(status.label), \(look.text)")
    }

    private static func look(_ days: Int) -> (text: String, foreground: Color, background: Color) {
        switch days {
        case ..<0:
            return ("Venció hace \(-days) d", CooklyTheme.danger, CooklyTheme.dangerSoft)
        case 0:
            return ("Vence hoy", CooklyTheme.danger, CooklyTheme.dangerSoft)
        case 1:
            return ("Vence mañana", CooklyTheme.warning, CooklyTheme.warningSoft)
        default:
            return ("\(days) días", CooklyTheme.success, CooklyTheme.successSoft)
        }
    }
}

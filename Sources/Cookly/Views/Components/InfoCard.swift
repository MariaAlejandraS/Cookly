import SwiftUI

struct InfoCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: CooklyTheme.space8) {
            Text(title)
                .font(CooklyTheme.rounded(.headline, weight: .semibold))
                .foregroundStyle(CooklyTheme.ink)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }
}

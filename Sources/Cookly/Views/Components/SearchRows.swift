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

struct SearchResultRow: View {
    let product: OFFProduct

    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            AsyncImage(url: URL(string: product.imageURL ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "photo")
                    .foregroundStyle(CooklyTheme.brandForeground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(CooklyTheme.canvas)
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))

            VStack(alignment: .leading, spacing: CooklyTheme.space4) {
                Text(product.displayName)
                    .font(CooklyTheme.rounded(.headline, weight: .semibold))
                    .foregroundStyle(CooklyTheme.ink)
                    .lineLimit(2)
                Text([product.brands, product.quantity].compactMap { $0 }.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            if let grade = product.nutriscoreGrade, grade.count == 1 {
                NutriScoreBadge(grade: grade)
            }
        }
        .cardStyle()
    }
}

struct SearchSkeletonRow: View {
    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            RoundedRectangle(cornerRadius: CooklyTheme.radius12).frame(width: 56, height: 56)
            VStack(alignment: .leading, spacing: 6) {
                Text("Nombre del alimento")
                Text("Marca · cantidad")
            }
            Spacer()
            Text("A").frame(width: 36, height: 36)
        }
        .cardStyle()
        .redacted(reason: .placeholder)
    }
}

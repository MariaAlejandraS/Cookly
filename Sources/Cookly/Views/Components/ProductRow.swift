import SwiftUI

struct ProductRow: View {
    let product: Product

    var body: some View {
        HStack(spacing: CooklyTheme.space12) {
            thumbnail
            VStack(alignment: .leading, spacing: CooklyTheme.space4) {
                Text(product.name)
                    .font(CooklyTheme.rounded(.headline, weight: .semibold))
                    .foregroundStyle(CooklyTheme.ink)
                    .lineLimit(2)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 8)
            ExpiryBadge(status: product.status, daysLeft: product.daysLeft)
        }
        .cardStyle()
        .accessibilityElement(children: .combine)
    }

    private var subtitle: String {
        "\(product.category.rawValue) · x\(product.quantity)\(product.isOpened ? " · abierto" : "")"
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let urlString = product.imageURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                IconTile(systemName: product.category.icon, size: 48)
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
        } else {
            IconTile(systemName: product.category.icon, size: 48)
        }
    }
}

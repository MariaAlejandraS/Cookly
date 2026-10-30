import SwiftUI

/// Cuadrícula de categorías. Comparte el binding con el Picker del formulario.
struct CategoryGrid: View {
    @Binding var selection: FoodCategory
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: CooklyTheme.space8) {
            ForEach(FoodCategory.allCases) { category in
                Button {
                    selection = category
                } label: {
                    VStack(spacing: CooklyTheme.space8) {
                        Image(systemName: category.icon)
                            .font(.title3)
                            .accessibilityHidden(true)
                        Text(category.rawValue)
                            .font(.caption2.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.7)
                    }
                    .foregroundStyle(selection == category ? CooklyTheme.onGradient : CooklyTheme.ink)
                    .frame(maxWidth: .infinity, minHeight: 92)
                    .padding(CooklyTheme.space8)
                    .background {
                        if selection == category {
                            RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous)
                                .fill(CooklyTheme.brandGradient)
                        } else {
                            RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous)
                                .fill(CooklyTheme.canvas)
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous)
                            .stroke(selection == category ? CooklyTheme.primary : Color.clear, lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(category.rawValue)
                .accessibilityAddTraits(selection == category ? .isSelected : [])
            }
        }
    }
}

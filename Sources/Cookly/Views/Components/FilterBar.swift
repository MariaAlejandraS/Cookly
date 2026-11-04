import SwiftUI

/// Filtro de la nevera. El estado sigue siendo un @Binding del ViewModel.
struct FilterBar: View {
    @Binding var selection: NeveraViewModel.StatusFilter

    var body: some View {
        HStack(spacing: CooklyTheme.space8) {
            ForEach(NeveraViewModel.StatusFilter.allCases) { filter in
                Button {
                    withAnimation(.snappy) { selection = filter }
                } label: {
                    Text(filter.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundStyle(selection == filter ? CooklyTheme.onGradient : CooklyTheme.ink)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background {
                            if selection == filter {
                                Capsule().fill(CooklyTheme.brandGradient)
                            } else {
                                Capsule().fill(CooklyTheme.surface)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(selection == filter ? .isSelected : [])
            }
        }
    }
}

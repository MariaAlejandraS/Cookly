import SwiftUI

struct CooklyShadow: ViewModifier {
    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content.shadow(
            color: .black.opacity(scheme == .dark ? 0.35 : 0.08),
            radius: 14,
            y: 6
        )
    }
}

struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(CooklyTheme.space16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(CooklyTheme.surface, in: RoundedRectangle(cornerRadius: CooklyTheme.radius16, style: .continuous))
            .modifier(CooklyShadow())
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardStyle()) }

    func cooklyShadow() -> some View { modifier(CooklyShadow()) }

    func cooklyScreen() -> some View {
        background(CooklyTheme.canvas.ignoresSafeArea())
    }

    func cooklyField() -> some View {
        padding(CooklyTheme.space12)
            .background(CooklyTheme.canvas, in: RoundedRectangle(cornerRadius: CooklyTheme.radius12, style: .continuous))
    }

    func cooklyListRow() -> some View {
        listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
    }

    func cooklyTabBar() -> some View {
        toolbarBackground(.ultraThinMaterial, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }
}

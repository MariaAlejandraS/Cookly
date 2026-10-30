import SwiftUI

/// Raíz: bienvenida o pestañas. El tinte y la barra usan la marca.
struct ContentView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("darkMode") private var darkMode = false
    @State private var tab = 0

    var body: some View {
        Group {
            if userName.isEmpty {
                WelcomeView()
            } else {
                TabView(selection: $tab) {
                    NeveraView(onSearch: { tab = 1 })
                        .cooklyTabBar()
                        .tabItem { Label("Nevera", systemImage: "refrigerator.fill") }
                        .tag(0)
                    SearchView()
                        .cooklyTabBar()
                        .tabItem { Label("Buscar", systemImage: "magnifyingglass") }
                        .tag(1)
                    RemindersView()
                        .cooklyTabBar()
                        .tabItem { Label("Recordatorios", systemImage: "bell.fill") }
                        .tag(2)
                    ProfileView()
                        .cooklyTabBar()
                        .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                        .tag(3)
                }
                .cooklyTabBar()
            }
        }
        .tint(CooklyTheme.brandForeground)
        .preferredColorScheme(darkMode ? .dark : .light)
    }
}

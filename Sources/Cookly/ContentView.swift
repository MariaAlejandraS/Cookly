import SwiftUI

/// Raíz: autenticación o pestañas. El tinte y la barra usan la marca.
struct ContentView: View {
    @EnvironmentObject private var session: SessionManager
    @AppStorage("darkMode") private var darkMode = false
    @State private var tab = 0

    var body: some View {
        Group {
            if let user = session.currentUser {
                TabView(selection: $tab) {
                    NeveraView(ownerId: user.id, onSearch: { tab = 1 })
                        .cooklyTabBar()
                        .tabItem { Label("Nevera", systemImage: "refrigerator.fill") }
                        .tag(0)
                    ScanView(ownerId: user.id)
                        .cooklyTabBar()
                        .tabItem { Label("Escanear", systemImage: "camera.viewfinder") }
                        .tag(1)
                    RemindersView(ownerId: user.id)
                        .cooklyTabBar()
                        .tabItem { Label("Recordatorios", systemImage: "bell.fill") }
                        .tag(2)
                    ProfileView()
                        .cooklyTabBar()
                        .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                        .tag(3)
                }
                .id(user.id)
                .cooklyTabBar()
            } else {
                LoginView()
                    .id(session.formEpoch)
            }
        }
        .tint(CooklyTheme.brandForeground)
        .preferredColorScheme(darkMode ? .dark : .light)
        .onChange(of: session.currentUser?.id) { _, _ in
            tab = 0
        }
    }
}

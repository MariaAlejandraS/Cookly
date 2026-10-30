import SwiftUI

struct ToastView: View {
    let message: String

    var body: some View {
        HStack(spacing: CooklyTheme.space8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(CooklyTheme.secondary)
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, CooklyTheme.space16)
        .frame(minHeight: 44)
        .background(Color(hex: 0x1A1A1A), in: Capsule())
        .accessibilityLabel(message)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    var bottom: CGFloat
    @State private var ticket = 0

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isPresented {
                    ToastView(message: message)
                        .padding(.horizontal, CooklyTheme.space16)
                        .padding(.bottom, bottom)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.snappy, value: isPresented)
            .onChange(of: isPresented) { _, shown in
                guard shown else { return }
                ticket += 1
                let current = ticket
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    guard current == ticket else { return }
                    isPresented = false
                }
            }
    }
}

extension View {
    func toast(isPresented: Binding<Bool>, message: String, bottom: CGFloat = 24) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, bottom: bottom))
    }
}

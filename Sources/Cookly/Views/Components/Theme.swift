import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }

    init(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        self.init(hex: UInt32(value))
    }

    /// UIColor dinámico: un hex en claro y otro en oscuro.
    static func adaptive(light: UInt32, dark: UInt32) -> Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
        #elseif canImport(AppKit)
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(hex: isDark ? dark : light)
        }))
        #else
        Color(hex: light)
        #endif
    }
}

#if canImport(UIKit)
private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#elseif canImport(AppKit)
private extension NSColor {
    convenience init(hex: UInt32) {
        self.init(
            srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif

/// Tokens de Cookly. El texto sobre el gradiente usa tinta fija #111111:
/// el blanco sobre #2FBDA8 no llega a contraste.
enum CooklyTheme {
    static let primary = Color(hex: 0x188489)
    static let secondary = Color(hex: 0x2FBDA8)
    static let ink = Color.adaptive(light: 0x111111, dark: 0xF4F7F7)
    static let onGradient = Color(hex: 0x111111)
    /// Texto sobre un color semántico que se invierte en oscuro.
    static let onFill = Color.adaptive(light: 0xFFFFFF, dark: 0x111111)
    static let brandForeground = Color.adaptive(light: 0x146E72, dark: 0x7AD9CF)
    static let canvas = Color.adaptive(light: 0xF3F7F6, dark: 0x101615)
    static let surface = Color.adaptive(light: 0xFFFFFF, dark: 0x1C2624)
    static let danger = Color.adaptive(light: 0xB42318, dark: 0xFFB4AB)
    static let dangerSoft = Color.adaptive(light: 0xFDECEA, dark: 0x3B2220)
    static let warning = Color.adaptive(light: 0x8A5A00, dark: 0xFFD18A)
    static let warningSoft = Color.adaptive(light: 0xFFF3DC, dark: 0x3A2E1A)
    static let success = Color.adaptive(light: 0x0E7A45, dark: 0x8EE0B0)
    static let successSoft = Color.adaptive(light: 0xE5F6EC, dark: 0x173328)
    static let cardBackground = surface
    static let cornerRadius: CGFloat = 16

    static let space4: CGFloat = 4
    static let space8: CGFloat = 8
    static let space12: CGFloat = 12
    static let space16: CGFloat = 16
    static let space24: CGFloat = 24
    static let space32: CGFloat = 32
    static let radius12: CGFloat = 12
    static let radius16: CGFloat = 16
    static let radius24: CGFloat = 24

    static var brandGradient: LinearGradient {
        LinearGradient(colors: [secondary, primary], startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static func rounded(_ style: Font.TextStyle, weight: Font.Weight) -> Font {
        .system(style, design: .rounded).weight(weight)
    }
}

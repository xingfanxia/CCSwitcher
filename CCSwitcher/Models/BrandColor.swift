import SwiftUI
import AppKit

extension Color {
    /// CCSwitcher brand color.
    // static let brand = Color(red: 0x7C / 255.0, green: 0x3A / 255.0, blue: 0xED / 255.0) // #7C3AED
    static let brand = Color(red: 0xE8 / 255.0, green: 0x6D / 255.0, blue: 0x45 / 255.0) // #E86D45

    /// Creates a color that automatically adapts between light and dark appearance.
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(nsColor: NSColor(name: nil, dynamicProvider: { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            return NSColor(isDark ? dark : light)
        }))
    }

    // MARK: - Card

    /// Standard card fill.
    static let cardFill = Color.white.opacity(0.20)
    /// Emphasized card fill (e.g. active account row).
    static let cardFillStrong = Color.white.opacity(0.25)
    /// Standard card border.
    static let cardBorder = Color.white.opacity(0.40)

    // MARK: - Tab Bar

    /// Tab bar background fill.
    static let tabFill = Color.white.opacity(0.15)
    /// Tab bar border.
    static let tabBorder = Color.white.opacity(0.40)

    // MARK: - Subtle Backgrounds

    /// Subtle brand tint for banners and badges.
    static let subtleBrand = adaptive(light: brand.opacity(0.12), dark: brand.opacity(0.28))
    /// Progress bar track.
    static let progressTrack = adaptive(light: Color.gray.opacity(0.18), dark: Color.gray.opacity(0.38))
}

extension ShapeStyle where Self == Color {
    static var brand: Color { .brand }
    static var cardFill: Color { .cardFill }
    static var cardFillStrong: Color { .cardFillStrong }
    static var cardBorder: Color { .cardBorder }
    static var tabFill: Color { .tabFill }
    static var tabBorder: Color { .tabBorder }
    static var subtleBrand: Color { .subtleBrand }
    static var progressTrack: Color { .progressTrack }
}

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

    // MARK: - Card Fills

    /// Active/brand card background.
    static let cardFill = adaptive(light: Color.white.opacity(0.15), dark: Color.white.opacity(0.15))
    /// Stronger active card background (e.g. active account row).
    static let cardFillStrong = adaptive(light: Color.white.opacity(0.20), dark: Color.white.opacity(0.20))
    /// Neutral/inactive card background.
    static let cardFillNeutral = adaptive(light: Color.white.opacity(0.15), dark: Color.white.opacity(0.15))
    /// Green-tinted card background (cost cards).
    static let cardFillGreen = adaptive(light: Color.white.opacity(0.15), dark: Color.white.opacity(0.15))

    // MARK: - Card Borders

    /// Brand-colored card border.
    static let cardBorderBrand = adaptive(light: Color.white.opacity(0.40), dark: Color.white.opacity(0.40))
    /// Neutral card border.
    static let cardBorderNeutral = adaptive(light: Color.white.opacity(0.40), dark: Color.white.opacity(0.40))
    /// Green card border (cost cards).
    static let cardBorderGreen = adaptive(light: Color.white.opacity(0.40), dark: Color.white.opacity(0.40))

    // MARK: - Subtle Backgrounds

    /// Subtle brand tint for banners and badges.
    static let subtleBrand = adaptive(light: brand.opacity(0.12), dark: brand.opacity(0.28))
    /// Tab bar outer background.
    static let tabBackground = adaptive(light: Color.gray.opacity(0.12), dark: Color.gray.opacity(0.22))
    /// Tab bar selected indicator — no longer used, brand color applied directly.
    static let tabSelected = adaptive(light: brand.opacity(0.32), dark: brand.opacity(0.52))
    /// Progress bar track.
    static let progressTrack = adaptive(light: Color.gray.opacity(0.18), dark: Color.gray.opacity(0.38))
}

extension ShapeStyle where Self == Color {
    static var brand: Color { .brand }
    static var cardFill: Color { .cardFill }
    static var cardFillStrong: Color { .cardFillStrong }
    static var cardFillNeutral: Color { .cardFillNeutral }
    static var cardFillGreen: Color { .cardFillGreen }
    static var cardBorderBrand: Color { .cardBorderBrand }
    static var cardBorderNeutral: Color { .cardBorderNeutral }
    static var cardBorderGreen: Color { .cardBorderGreen }
    static var subtleBrand: Color { .subtleBrand }
    static var tabBackground: Color { .tabBackground }
    static var tabSelected: Color { .tabSelected }
    static var progressTrack: Color { .progressTrack }
}

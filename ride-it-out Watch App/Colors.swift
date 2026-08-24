import SwiftUI

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    // watchOS has no Appearance control of its own, so the watch app uses the
    // dark palette values directly rather than the light/dark scheme() helper
    // the iOS target uses (UIColor's dynamic-provider trait API isn't
    // available on watchOS).

    // Core backgrounds
    static let background    = Color(hex: 0x17130F)
    static let surface       = Color(hex: 0x221C17)
    static let surfaceRaised = Color(hex: 0x2C251E)
    static let borderColor   = Color(hex: 0xF5EAD8, alpha: 0.14)

    // Text
    static let textPrimary   = Color(hex: 0xF5EAD8)
    static let textSecondary = Color(hex: 0xA19786)
    static let textTertiary  = Color(hex: 0x82796A)

    // Accent
    static let accent     = Color(hex: 0xF6A06B)
    static let accentOn   = Color(hex: 0x2E2B25)
    static let accentText = Color(hex: 0xF6A06B)

    // Sage — lifelines
    static let sageDeep = Color(hex: 0xAEBF92)
    static let sageOn   = Color(hex: 0x272E1B)

    // Status
    static let destructiveRed = Color(hex: 0xE0836F)

    // Grounding zone background
    static let groundingBackground = Color(hex: 0x221C17)

    // Overlay over grounding media
    static let mediaWash = Color(hex: 0x17130F, alpha: 0.34)
}

/// Breath-phase colors — band (solid edge), fill (soft trough), label (phase text).
extension PhaseType {
    var bandColor: Color {
        switch self {
        case .inhale:          return Color(hex: 0xF6A06B)
        case .holdAfterInhale: return Color(hex: 0xAEBF92)
        case .exhale:          return Color(hex: 0x8FB3C4)
        case .holdAfterExhale: return Color(hex: 0x82796A)
        }
    }

    var fillColor: Color {
        switch self {
        case .inhale:          return Color(hex: 0x3F2C1F)
        case .holdAfterInhale: return Color(hex: 0x2F3626)
        case .exhale:          return Color(hex: 0x26333A)
        case .holdAfterExhale: return Color(hex: 0x3A3129)
        }
    }

    var labelColor: Color {
        switch self {
        case .inhale:          return Color(hex: 0xF6A06B)
        case .holdAfterInhale: return Color(hex: 0xCCDBB2)
        case .exhale:          return Color(hex: 0xA9CAD8)
        case .holdAfterExhale: return Color(hex: 0xA19786)
        }
    }
}

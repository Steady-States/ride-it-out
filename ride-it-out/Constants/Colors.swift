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

    static func scheme(_ light: Color, _ dark: Color) -> Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light) })
    }

    // Core backgrounds
    static let background    = scheme(Color(hex: 0xF5EAD8), Color(hex: 0x17130F))
    static let surface       = scheme(Color(hex: 0xEBDDC5), Color(hex: 0x221C17))
    static let surfaceRaised = scheme(Color(hex: 0xF9F4ED), Color(hex: 0x2C251E))
    static let tint          = scheme(Color(hex: 0xEEE7DB), Color(hex: 0x3A3129))
    static let borderColor   = scheme(Color(hex: 0x201E1D, alpha: 0.14), Color(hex: 0xF5EAD8, alpha: 0.14))

    // Text
    static let textPrimary   = scheme(Color(hex: 0x201E1D), Color(hex: 0xF5EAD8))
    static let textSecondary = scheme(Color(hex: 0x645C50), Color(hex: 0xA19786))
    static let textTertiary  = scheme(Color(hex: 0x82796A), Color(hex: 0x82796A))

    // Accent
    static let accent        = scheme(Color(hex: 0xC67139), Color(hex: 0xF6A06B))
    static let accentOn      = scheme(Color(hex: 0xF9F4ED), Color(hex: 0x2E2B25))
    static let accentText    = scheme(Color(hex: 0x8C491A), Color(hex: 0xF6A06B))
    static let accentFill    = scheme(Color(hex: 0xFFE1D0), Color(hex: 0x4A3325))

    // Sage — lifelines
    static let sageFill      = scheme(Color(hex: 0xE1EECC), Color(hex: 0x333A28))
    static let sageDeep      = scheme(Color(hex: 0x56633F), Color(hex: 0xAEBF92))
    static let sageOn        = scheme(Color(hex: 0xF0FAE1), Color(hex: 0x272E1B))
    static let sageText      = scheme(Color(hex: 0x3D472B), Color(hex: 0xCCDBB2))

    // Status
    static let destructive     = scheme(Color(hex: 0x9C3B28), Color(hex: 0xE0836F))
    static let destructiveFill = scheme(Color(hex: 0xF7DDD6), Color(hex: 0x48281F))

    // Overlays
    static let scrim      = scheme(Color(hex: 0xF9F4ED, alpha: 0.86), Color(hex: 0x2C251E, alpha: 0.88))
    static let scrimHeavy = scheme(Color(hex: 0x2E2B25, alpha: 0.58), Color(hex: 0x0A0806, alpha: 0.68))
    static let mediaWash  = scheme(Color(hex: 0xF5EAD8, alpha: 0.22), Color(hex: 0x17130F, alpha: 0.34))
    static let onMedia    = scheme(Color(hex: 0xF9F4ED), Color(hex: 0xF5EAD8))
}

/// Breath-phase colors — band (solid edge/crest), fill (soft trough), label (phase text).
extension PhaseType {
    var bandColor: Color {
        switch self {
        case .inhale:          return .scheme(Color(hex: 0xC67139), Color(hex: 0xF6A06B))
        case .holdAfterInhale: return .scheme(Color(hex: 0x8FA073), Color(hex: 0xAEBF92))
        case .exhale:          return .scheme(Color(hex: 0x4A6F82), Color(hex: 0x8FB3C4))
        case .holdAfterExhale: return .scheme(Color(hex: 0xA19786), Color(hex: 0x82796A))
        }
    }

    var fillColor: Color {
        switch self {
        case .inhale:          return .scheme(Color(hex: 0xFFE1D0), Color(hex: 0x3F2C1F))
        case .holdAfterInhale: return .scheme(Color(hex: 0xE1EECC), Color(hex: 0x2F3626))
        case .exhale:          return .scheme(Color(hex: 0xDBE6EC), Color(hex: 0x26333A))
        case .holdAfterExhale: return .scheme(Color(hex: 0xEEE7DB), Color(hex: 0x3A3129))
        }
    }

    var labelColor: Color {
        switch self {
        case .inhale:          return .scheme(Color(hex: 0x8C491A), Color(hex: 0xF6A06B))
        case .holdAfterInhale: return .scheme(Color(hex: 0x56633F), Color(hex: 0xCCDBB2))
        case .exhale:          return .scheme(Color(hex: 0x33566A), Color(hex: 0xA9CAD8))
        case .holdAfterExhale: return .scheme(Color(hex: 0x645C50), Color(hex: 0xA19786))
        }
    }
}

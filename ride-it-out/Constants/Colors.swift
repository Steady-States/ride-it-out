import SwiftUI

extension Color {
    // Core backgrounds
    static let background    = Color(red: 0.051, green: 0.059, blue: 0.102) // #0D0F1A
    static let surface       = Color(red: 0.078, green: 0.090, blue: 0.161) // #141729
    static let surfaceRaised = Color(red: 0.110, green: 0.125, blue: 0.220) // #1C2038
    static let borderColor   = Color(red: 0.165, green: 0.176, blue: 0.271) // #2A2D45

    // Text
    static let textPrimary   = Color(red: 0.941, green: 0.949, blue: 1.000) // #F0F2FF
    static let textSecondary = Color(red: 0.541, green: 0.561, blue: 0.678) // #8A8FAD
    static let textTertiary  = Color(red: 0.333, green: 0.345, blue: 0.459) // #555875

    // Accent
    static let accentCyan    = Color(red: 0.310, green: 0.765, blue: 0.969) // #4FC3F7
    static let accentWarm    = Color(red: 1.000, green: 0.702, blue: 0.278) // #FFB347

    // Lifelines
    static let lifeline      = Color(red: 0.180, green: 0.490, blue: 0.549) // #2E7D8C
    static let lifelineEmpty = Color(red: 0.110, green: 0.165, blue: 0.188) // #1C2A30

    // Status
    static let destructiveRed = Color(red: 0.878, green: 0.322, blue: 0.322) // #E05252

    // Grounding zone background
    static let groundingBackground = Color(red: 0.059, green: 0.071, blue: 0.125) // #0F1220

    // Glow — per breathing phase
    static let glowInhale   = accentWarm                                           // #FFB347 warm amber
    static let glowHoldIn   = Color(red: 0.627, green: 0.745, blue: 0.784)        // #A0BEC8 muted blue
    static let glowExhale   = accentCyan                                           // #4FC3F7 cool blue
    static let glowHoldOut  = Color(red: 0.376, green: 0.565, blue: 0.627)        // #6090A0 darker muted

    // Legacy aliases removed
}

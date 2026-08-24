import SwiftUI

extension Font {
    /// Screen titles and the wordmark use Instrument Serif per the design handoff.
    /// Falls back to the system serif face if the "Instrument Serif" font asset
    /// hasn't been added to the app bundle yet.
    static func displaySerif(size: CGFloat) -> Font {
        #if canImport(UIKit)
        if UIFont(name: "InstrumentSerif-Regular", size: size) != nil {
            return .custom("InstrumentSerif-Regular", size: size)
        }
        #endif
        return .system(size: size, weight: .regular, design: .serif)
    }
}

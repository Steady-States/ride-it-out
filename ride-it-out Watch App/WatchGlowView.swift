import SwiftUI

/// Edge band — a solid inset border that recolors with the breath phase.
struct WatchGlowView: View {
    @ObservedObject var breathingVM: WatchBreathingViewModel

    var body: some View {
        RoundedRectangle(cornerRadius: 46)
            .inset(by: 2.5)
            .stroke(breathingVM.bandColor, lineWidth: 5)
            .animation(.linear(duration: 0.5), value: breathingVM.bandColor)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

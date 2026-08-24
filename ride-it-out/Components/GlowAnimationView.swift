import SwiftUI

/// Edge band — a solid inset border that recolors with the breath phase.
/// No blur, no opacity pulsing; only color crossfades on phase change.
struct GlowAnimationView: View {
    @ObservedObject var breathingVM: BreathingViewModel

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 40)
                .inset(by: 3.5)
                .stroke(breathingVM.bandColor, lineWidth: 7)

            RoundedRectangle(cornerRadius: 33)
                .inset(by: 7.75)
                .stroke(breathingVM.bandColor.opacity(0.35), lineWidth: 1.5)
        }
        .animation(.linear(duration: 0.5), value: breathingVM.bandColor)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

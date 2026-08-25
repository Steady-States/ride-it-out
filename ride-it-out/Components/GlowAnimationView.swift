import SwiftUI

private extension UIScreen {
    // Apple doesn't expose this publicly; every iPhone since the X has a
    // different physical bezel curve (mini ~44pt up to Pro Max ~63pt), and a
    // fixed radius either leaves a flat sliver in the corner or overshoots.
    var displayCornerRadius: CGFloat {
        value(forKey: "_displayCornerRadius") as? CGFloat ?? 40
    }
}

/// Edge band — a solid inset border that recolors with the breath phase.
/// No blur, no opacity pulsing; only color crossfades on phase change.
struct GlowAnimationView: View {
    @ObservedObject var breathingVM: BreathingViewModel

    private var outerRadius: CGFloat {
        UIScreen.main.displayCornerRadius
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: outerRadius, style: .continuous)
                .inset(by: 3.5)
                .stroke(breathingVM.bandColor, lineWidth: 7)

            RoundedRectangle(cornerRadius: outerRadius - 7, style: .continuous)
                .inset(by: 7.75)
                .stroke(breathingVM.bandColor.opacity(0.35), lineWidth: 1.5)
        }
        .animation(.linear(duration: 0.5), value: breathingVM.bandColor)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

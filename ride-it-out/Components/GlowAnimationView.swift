import SwiftUI

struct GlowAnimationView: View {
    @ObservedObject var breathingVM: BreathingViewModel

    var body: some View {
        ZStack {
            // Outer glow — wider, softer diffusion at edge
            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 16)
                .blur(radius: 24)
                .opacity(breathingVM.glowIntensity * 0.6)
                .ignoresSafeArea()

            // Inner glow — tighter, more intense at edge
            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 8)
                .blur(radius: 12)
                .opacity(breathingVM.glowIntensity * 0.9)
                .ignoresSafeArea()

            // Core edge line — sharpest, most defined
            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 3)
                .blur(radius: 4)
                .opacity(breathingVM.glowIntensity)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

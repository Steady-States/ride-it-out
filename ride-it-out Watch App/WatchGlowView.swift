import SwiftUI

struct WatchGlowView: View {
    @ObservedObject var breathingVM: WatchBreathingViewModel

    var body: some View {
        ZStack {
            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 10)
                .blur(radius: 14)
                .opacity(breathingVM.glowIntensity * 0.6)
                .ignoresSafeArea()

            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 5)
                .blur(radius: 7)
                .opacity(breathingVM.glowIntensity * 0.9)
                .ignoresSafeArea()

            Rectangle()
                .stroke(breathingVM.glowColor, lineWidth: 2)
                .blur(radius: 2)
                .opacity(breathingVM.glowIntensity)
                .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
}

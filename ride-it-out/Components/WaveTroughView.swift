import SwiftUI

private struct WaveCrestShape: Shape {
    var phase: CGFloat
    var wavelength: CGFloat = 70

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.height / 2
        path.move(to: CGPoint(x: 0, y: midY))
        var x: CGFloat = 0
        while x <= rect.width {
            let relativeX = x / wavelength
            let y = midY + sin(relativeX * 2 * .pi + phase * 2 * .pi) * midY
            path.addLine(to: CGPoint(x: x, y: y))
            x += 2
        }
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}

/// The breathing trough: a fill that rises and drains with the phase, topped
/// by a drifting wave crest, with the beat count centered over the whole thing.
struct WaveTroughView: View {
    @ObservedObject var vm: BreathingViewModel
    @State private var drift: CGFloat = 0
    @Environment(\.colorScheme) private var colorScheme

    // The beat digit uses `.contentTransition(.numericText())`, which renders
    // through a Core Animation snapshot that doesn't reliably pick up the
    // dynamic-provider UIColor tokens' light/dark resolution — it can paint
    // using the wrong branch and vanish against the trough background. Read
    // the scheme explicitly here instead of going through `Color.textPrimary`.
    private var beatTextColor: Color {
        colorScheme == .dark ? Color(hex: 0xF5EAD8) : Color(hex: 0x201E1D)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.surfaceRaised

                vm.currentPhase.type.fillColor
                    .frame(height: max(0, geo.size.height * vm.troughTarget))
                    .overlay(alignment: .top) {
                        ZStack(alignment: .top) {
                            WaveCrestShape(phase: drift)
                                .fill(vm.currentPhase.type.bandColor.opacity(0.55))
                                .frame(height: 12)
                            Rectangle()
                                .fill(vm.currentPhase.type.bandColor.opacity(0.8))
                                .frame(height: 2)
                        }
                        .offset(y: -6)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .animation(.linear(duration: vm.troughDuration), value: vm.troughTarget)

                Text(vm.isRunning ? "\(vm.currentBeat)" : "—")
                    .font(.system(size: 54, weight: .light))
                    .foregroundColor(beatTextColor)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: vm.currentBeat)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                drift = 1
            }
        }
    }
}

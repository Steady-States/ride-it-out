import SwiftUI

private struct WaveCrestShape: Shape {
    var phase: CGFloat
    var wavelength: CGFloat = 40

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

/// Full-screen breathing trough for watchOS: the fill rises and drains
/// against `surface`, topped by a drifting wave crest.
struct WatchWaveTroughView: View {
    @ObservedObject var vm: WatchBreathingViewModel
    @State private var drift: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.surface

                vm.currentPhase.type.fillColor
                    .frame(height: max(0, geo.size.height * vm.troughTarget))
                    .overlay(alignment: .top) {
                        ZStack(alignment: .top) {
                            WaveCrestShape(phase: drift)
                                .fill(vm.currentPhase.type.bandColor.opacity(0.55))
                                .frame(height: 8)
                            Rectangle()
                                .fill(vm.currentPhase.type.bandColor.opacity(0.8))
                                .frame(height: 1.5)
                        }
                        .offset(y: -4)
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .animation(.linear(duration: vm.troughDuration), value: vm.troughTarget)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 5).repeatForever(autoreverses: false)) {
                drift = 1
            }
        }
    }
}

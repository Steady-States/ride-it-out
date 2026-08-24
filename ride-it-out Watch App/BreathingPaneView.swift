import SwiftUI

struct BreathingPaneView: View {
    @ObservedObject var vm: WatchBreathingViewModel
    @State private var modalityIndex: Int = 0

    var body: some View {
        TabView(selection: $modalityIndex) {
            ForEach(Array(BreathingModalities.all.enumerated()), id: \.offset) { index, modality in
                breathingPage(for: modality)
                    .tag(index)
            }
        }
        .tabViewStyle(.page)
        .onChange(of: modalityIndex) { _, newValue in
            vm.start(modality: BreathingModalities.all[newValue])
        }
    }

    private func breathingPage(for modality: BreathingModality) -> some View {
        ZStack {
            WatchWaveTroughView(vm: vm)
            WatchGlowView(breathingVM: vm)

            VStack {
                Spacer()
                VStack(spacing: 4) {
                    Text(vm.isRunning && vm.currentModality.id == modality.id ? "\(vm.currentBeat)" : "—")
                        .font(.system(size: 58, weight: .light))
                        .foregroundColor(.textPrimary)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: vm.currentBeat)

                    Text(vm.isRunning ? vm.currentPhase.label : "READY")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2.6)
                        .foregroundColor(vm.isRunning ? vm.currentPhase.type.labelColor : .textTertiary)
                }
                Spacer()
                Text(modality.label)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, 6)
            }
        }
    }
}

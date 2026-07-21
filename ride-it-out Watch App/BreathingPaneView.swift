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
            Color.background.ignoresSafeArea()
            WatchGlowView(breathingVM: vm)

            VStack {
                Spacer()
                Text(vm.isRunning && vm.currentModality.id == modality.id ? "\(vm.currentBeat)" : "—")
                    .font(.system(size: 48, weight: .thin))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: vm.currentBeat)
                Spacer()
                Text(modality.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .padding(.bottom, 6)
            }
        }
    }
}

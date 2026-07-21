import SwiftUI

struct BreathingZoneView: View {
    @ObservedObject var vm: BreathingViewModel
    var onSettingsTap: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.currentPhase.label)
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.textSecondary)
                    .tracking(3)

                Text("\(vm.currentBeat)")
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    .foregroundColor(.textPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: vm.currentBeat)
            }

            Spacer()

            HStack(spacing: 16) {
                Button {
                    vm.isRunning ? vm.stop() : vm.restart()
                } label: {
                    Text(vm.isRunning ? "■" : "▶")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundColor(.accentCyan)
                        .frame(width: 44, height: 44)
                }

                Button(action: onSettingsTap) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                        .frame(width: 44, height: 44)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

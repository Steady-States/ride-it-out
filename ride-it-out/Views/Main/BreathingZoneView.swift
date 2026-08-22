import SwiftUI

struct BreathingZoneView: View {
    @ObservedObject var vm: BreathingViewModel
    var selectedModality: BreathingModality
    var onPatternChange: (BreathingModality) -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Left half — phase label + play/stop + beat counter
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 10) {
                    Text(vm.isRunning ? vm.currentPhase.label : "· · ·")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                        .tracking(3)

                    Button {
                        vm.isRunning ? vm.stop() : vm.restart()
                    } label: {
                        Image(systemName: vm.isRunning ? "stop.fill" : "play.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.textSecondary)
                            .frame(width: 20, height: 20)
                    }
                }

                Text(vm.isRunning ? "\(vm.currentBeat)" : "—")
                    .font(.system(size: 72, weight: .thin))
                    .foregroundColor(.textPrimary)
                    .opacity(vm.isRunning ? 1 : 0.4)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.easeInOut(duration: 0.2), value: vm.currentBeat)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 14)

            Rectangle()
                .fill(Color.borderColor)
                .frame(width: 1)
                .padding(.vertical, 12)

            // Right half — breathing method selector
            VStack(alignment: .leading, spacing: 5) {
                Text("METHOD")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.textTertiary)
                    .tracking(2)

                Menu {
                    ForEach(BreathingModalities.all) { modality in
                        Button {
                            onPatternChange(modality)
                        } label: {
                            if modality.id == selectedModality.id {
                                Label(modality.label, systemImage: "checkmark")
                            } else {
                                Text(modality.label)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Text(selectedModality.label)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.textSecondary)
                    }
                }

                Text(timingHint)
                    .font(.system(size: 11))
                    .foregroundColor(.textTertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(.trailing, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.surface)
        .overlay(alignment: .bottom) {
            Color.borderColor.frame(height: 0.5)
        }
    }

    private var timingHint: String {
        selectedModality.phases.map { phase in
            switch phase.type {
            case .inhale: return "\(phase.beats)s in"
            case .exhale: return "\(phase.beats)s out"
            case .holdAfterInhale, .holdAfterExhale: return "\(phase.beats)s hold"
            }
        }.joined(separator: " · ")
    }
}

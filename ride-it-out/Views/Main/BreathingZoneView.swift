import SwiftUI

struct BreathingZoneView: View {
    @ObservedObject var vm: BreathingViewModel
    var selectedModality: BreathingModality
    var onPatternChange: (BreathingModality) -> Void

    var body: some View {
        HStack(spacing: 14) {
            WaveTroughView(vm: vm)
                .frame(width: 132, height: 104)

            VStack(alignment: .leading, spacing: 2) {
                Text(vm.isRunning ? vm.currentPhase.label : "READY")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(3)
                    .foregroundColor(vm.isRunning ? vm.currentPhase.type.labelColor : .textTertiary)

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
                    HStack(spacing: 4) {
                        Text(selectedModality.label)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.textPrimary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }
                }

                Text(timingHint)
                    .font(.system(size: 12))
                    .foregroundColor(.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                vm.isRunning ? vm.stop() : vm.restart()
            } label: {
                Image(systemName: vm.isRunning ? "stop.fill" : "play.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .frame(width: 48, height: 48)
                    .background(Color.surfaceRaised)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.borderColor, lineWidth: 1))
            }
        }
        .padding(.horizontal, 18)
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

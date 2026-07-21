import SwiftUI

struct CustomizeBreathingView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var breathingVM: BreathingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionLabel("BREATHING PATTERN")
                SettingsCard {
                    ForEach(Array(BreathingModalities.all.enumerated()), id: \.element.id) { index, modality in
                        Button {
                            settingsVM.saveModalityID(modality.id)
                            breathingVM.restart()
                        } label: {
                            modalityRow(modality)
                        }
                        .buttonStyle(.plain)

                        if index < BreathingModalities.all.count - 1 {
                            Divider().background(Color.borderColor)
                        }
                    }
                }

                SectionLabel("HAPTICS")
                SettingsCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Haptic Feedback", isOn: Binding(
                            get: { settingsVM.hapticsEnabled },
                            set: { settingsVM.saveHapticsEnabled($0) }
                        ))
                        .tint(.accentCyan)
                        .foregroundColor(.textPrimary)
                        .font(.system(size: 14, weight: .medium))

                        Text("Gentle vibrations guide your inhale and exhale. Best experienced on a physical device.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                }
            }
            .padding(.top, 12)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Breathing")
        .preferredColorScheme(.dark)
    }

    @ViewBuilder
    private func modalityRow(_ modality: BreathingModality) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(modality.label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(modality.description)
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    ForEach(modality.phases, id: \.label) { phase in
                        Text("\(phase.beats)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(phaseColor(phase.type))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(phaseColor(phase.type).opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 4)
            }
            Spacer()
            if settingsVM.selectedModalityID == modality.id {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.accentCyan)
                    .font(.system(size: 18))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }

    private func phaseColor(_ type: PhaseType) -> Color {
        switch type {
        case .inhale: return .accentCyan
        case .exhale: return Color(red: 0.5, green: 0.8, blue: 0.6)
        case .holdAfterInhale, .holdAfterExhale: return .textSecondary
        }
    }
}

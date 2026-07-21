import SwiftUI

struct CustomizeBreathingView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var breathingVM: BreathingViewModel

    var body: some View {
        List {
            Section("Breathing Pattern") {
                ForEach(BreathingModalities.all) { modality in
                    Button {
                        settingsVM.saveModalityID(modality.id)
                        breathingVM.restart()
                    } label: {
                        HStack(alignment: .top, spacing: 14) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(modality.label)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.textPrimary)
                                Text(modality.description)
                                    .font(.system(size: 13))
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
                                    .font(.system(size: 20))
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }

            Section("Haptics") {
                Toggle("Haptic Feedback", isOn: Binding(
                    get: { settingsVM.hapticsEnabled },
                    set: { settingsVM.saveHapticsEnabled($0) }
                ))
                .tint(.accentCyan)

                Text("Gentle vibrations guide your inhale and exhale. Best experienced on a physical device.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            }
        }
        .navigationTitle("Breathing")
        .preferredColorScheme(.dark)
    }

    private func phaseColor(_ type: PhaseType) -> Color {
        switch type {
        case .inhale: return .accentCyan
        case .exhale: return Color(red: 0.5, green: 0.8, blue: 0.6)
        case .holdAfterInhale, .holdAfterExhale: return .textSecondary
        }
    }
}

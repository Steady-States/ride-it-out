import SwiftUI

struct CustomizeBreathingView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var breathingVM: BreathingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("BREATHING PATTERN")
                    .padding(.bottom, 0)

                ForEach(BreathingModalities.all) { modality in
                    Button {
                        settingsVM.saveModalityID(modality.id)
                        breathingVM.restart()
                    } label: {
                        modalityCard(modality)
                    }
                    .buttonStyle(.plain)
                }

                SectionLabel("HAPTICS")
                    .padding(.top, 4)
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Haptic Feedback", isOn: Binding(
                        get: { settingsVM.hapticsEnabled },
                        set: { settingsVM.saveHapticsEnabled($0) }
                    ))
                    .tint(.accent)
                    .foregroundColor(.textPrimary)
                    .font(.system(size: 16, weight: .medium))

                    Text("A soft pulse on every beat, so you can follow the pattern with the phone in your pocket or face-down.")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .background(Color.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Breathing")
    }

    @ViewBuilder
    private func modalityCard(_ modality: BreathingModality) -> some View {
        let isSelected = settingsVM.selectedModalityID == modality.id
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Text(modality.label)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Spacer()
                Circle()
                    .fill(isSelected ? Color.accent : Color.tint)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.accentOn)
                            .opacity(isSelected ? 1 : 0)
                    )
            }

            Text(modality.description)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
                .lineSpacing(6.5)
                .fixedSize(horizontal: false, vertical: true)

            proportionalTimeline(modality)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(Color.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(isSelected ? Color.accent : Color.clear, lineWidth: 1.5)
        )
    }

    private func proportionalTimeline(_ modality: BreathingModality) -> some View {
        let gapWidth: CGFloat = 3
        let totalBeats = CGFloat(modality.phases.reduce(0) { $0 + $1.beats })
        let gapCount = CGFloat(modality.phases.count - 1)

        return GeometryReader { geo in
            let availableWidth = max(0, geo.size.width - gapCount * gapWidth)
            HStack(spacing: gapWidth) {
                ForEach(Array(modality.phases.enumerated()), id: \.offset) { _, phase in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(phase.type.fillColor)
                        .frame(width: availableWidth * CGFloat(phase.beats) / totalBeats)
                        .overlay(
                            Text("\(phase.beats)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(phase.type.labelColor)
                        )
                }
            }
        }
        .frame(height: 26)
    }
}

import SwiftUI

/// The pill-track segmented control used for Appearance and the grounding
/// media source picker: a `tint` track with an `accent` pill on the selection.
struct SegmentedPicker<Option: Identifiable & Equatable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selection = option }
                } label: {
                    Text(label(option))
                        .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                        .foregroundColor(isSelected ? .accentOn : .textSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(isSelected ? Color.accent : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.tint)
        .clipShape(Capsule())
    }
}

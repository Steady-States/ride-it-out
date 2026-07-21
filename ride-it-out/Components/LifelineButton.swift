import SwiftUI

struct LifelineButton: View {
    let lifeline: Lifeline
    let displayMode: LifelineDisplayMode
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            if let url = URL(string: "tel://\(lifeline.phone)") {
                openURL(url)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.accentCyan.opacity(0.3), lineWidth: 1)
                    )

                VStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.accentCyan)
                    Text(lifeline.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
            }
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

struct EmptySlotButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.surfaceCard.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [6]))
                            .foregroundColor(Color.textSecondary.opacity(0.3))
                    )
                VStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 20))
                        .foregroundColor(.textSecondary)
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(12)
            }
        }
        .frame(minWidth: 44, minHeight: 44)
    }
}

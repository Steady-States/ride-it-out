import SwiftUI

struct LifelineButton: View {
    let lifeline: Lifeline
    @Environment(\.openURL) private var openURL
    @State private var pressed = false
    @State private var showActionSheet = false

    var body: some View {
        Button {
            showActionSheet = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.lifeline)

                VStack(spacing: 6) {
                    avatar

                    Text(lifeline.name.isEmpty ? lifeline.phone : lifeline.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
            }
        }
        .scaleEffect(pressed ? 0.96 : 1.0)
        .brightness(pressed ? 0.08 : 0)
        .animation(.spring(response: 0.15, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .frame(minWidth: 44, minHeight: 44)
        .confirmationDialog(
            lifeline.name.isEmpty ? lifeline.phone : lifeline.name,
            isPresented: $showActionSheet,
            titleVisibility: .visible
        ) {
            Button("Call") { call() }
            Button("Text Message") { text() }
            Button("Cancel", role: .cancel) {}
        }
    }

    @ViewBuilder
    private var avatar: some View {
        #if canImport(UIKit)
        if let data = lifeline.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 38, height: 38)
                .clipShape(Circle())
        } else {
            initialsAvatar
        }
        #else
        initialsAvatar
        #endif
    }

    private var initialsAvatar: some View {
        Circle()
            .fill(avatarColor)
            .frame(width: 38, height: 38)
            .overlay(
                Text(initials)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.textPrimary)
            )
    }

    private var initials: String {
        let source = lifeline.name.isEmpty ? lifeline.phone : lifeline.name
        let words = source.split(separator: " ").filter { $0.first?.isLetter == true }
        let result = String(words.prefix(2).compactMap(\.first)).uppercased()
        return result.isEmpty ? "#" : result
    }

    private var avatarColor: Color {
        let palette: [Color] = [
            Color(red: 0.239, green: 0.420, blue: 0.549), // #3D6B8C
            Color(red: 0.180, green: 0.490, blue: 0.361), // #2E7D5C
            Color(red: 0.231, green: 0.329, blue: 0.569), // #3B548F
            Color(red: 0.404, green: 0.286, blue: 0.573), // #674992
            Color(red: 0.569, green: 0.349, blue: 0.259), // #915943
        ]
        return palette[abs(lifeline.name.hashValue) % palette.count]
    }

    private var sanitizedPhone: String {
        lifeline.phone.filter { $0.isNumber || $0 == "+" }
    }

    private func call() {
        if let url = URL(string: "tel://\(sanitizedPhone)") {
            openURL(url)
        }
    }

    private func text() {
        if let url = URL(string: "sms://\(sanitizedPhone)") {
            openURL(url)
        }
    }
}

struct EmptySlotButton: View {
    let label: String
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.lifelineEmpty)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1.5, dash: [6])
                            )
                            .foregroundColor(Color.borderColor)
                    )

                VStack(spacing: 6) {
                    Text("+")
                        .font(.system(size: 20))
                        .foregroundColor(.textTertiary)
                    Text(label)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
            }
        }
        .scaleEffect(pressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.15, dampingFraction: 0.7), value: pressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
        .frame(minWidth: 44, minHeight: 44)
    }
}

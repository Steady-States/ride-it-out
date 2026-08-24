import SwiftUI

private struct PressableStyle: ViewModifier {
    @Binding var pressed: Bool
    var brighten: Bool = true

    func body(content: Content) -> some View {
        content
            .scaleEffect(pressed ? 0.96 : 1.0)
            .brightness(brighten && pressed ? 0.08 : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.7), value: pressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
            .frame(minWidth: 44, minHeight: 44)
    }
}

private extension View {
    func pressable(_ pressed: Binding<Bool>, brighten: Bool = true) -> some View {
        modifier(PressableStyle(pressed: pressed, brighten: brighten))
    }
}

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
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.sageFill)

                VStack(spacing: 8) {
                    avatar

                    Text(lifeline.name.isEmpty ? lifeline.phone : lifeline.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.sageText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                }
                .padding(12)
            }
        }
        .pressable($pressed)
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
                .frame(width: 46, height: 46)
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
            .fill(Color.sageDeep)
            .frame(width: 46, height: 46)
            .overlay(
                Text(lifeline.initials)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.sageOn)
            )
    }

    private func call() {
        if let url = lifeline.callURL {
            openURL(url)
        }
    }

    private func text() {
        if let url = lifeline.textURL {
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
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1.5, dash: [6])
                            )
                            .foregroundColor(Color.borderColor)
                    )

                VStack(spacing: 6) {
                    Text("+")
                        .font(.system(size: 26, weight: .light))
                        .foregroundColor(.textTertiary)
                    Text(label)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 10)
                }
            }
        }
        .pressable($pressed, brighten: false)
    }
}

import SwiftUI

struct LifelinePaneView: View {
    let lifeline: WatchLifeline
    @Environment(\.openURL) private var openURL
    @State private var showActionSheet = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 10) {
                avatar
                Text(lifeline.name.isEmpty ? lifeline.phone : lifeline.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16)
        }
        .contentShape(Rectangle())
        .onTapGesture { showActionSheet = true }
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
        if let data = lifeline.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.lifeline)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(initials)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.textPrimary)
                )
        }
    }

    private var initials: String {
        let source = lifeline.name.isEmpty ? lifeline.phone : lifeline.name
        let words = source.split(separator: " ").filter { $0.first?.isLetter == true }
        let result = String(words.prefix(2).compactMap(\.first)).uppercased()
        return result.isEmpty ? "#" : result
    }

    private func call() {
        if let url = lifeline.callURL { openURL(url) }
    }

    private func text() {
        if let url = lifeline.textURL { openURL(url) }
    }
}

struct EmptyLifelinePaneView: View {
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 26))
                    .foregroundColor(.textTertiary)
                Text("Add a lifeline on iPhone")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
        }
    }
}

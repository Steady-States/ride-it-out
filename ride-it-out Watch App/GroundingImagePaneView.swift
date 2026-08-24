import SwiftUI

struct GroundingImagePaneView: View {
    let imageData: Data?

    var body: some View {
        ZStack {
            Color.groundingBackground.ignoresSafeArea()

            if let imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .saturation(0.62)
                    .contrast(0.92)
                    .ignoresSafeArea()
                    .overlay(Color.mediaWash.ignoresSafeArea())
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 24))
                        .foregroundColor(.textSecondary.opacity(0.6))
                    Text("Set a grounding image on iPhone")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.textSecondary.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }
            }
        }
    }
}

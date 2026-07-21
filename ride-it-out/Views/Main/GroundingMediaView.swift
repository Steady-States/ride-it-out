import SwiftUI
import AVKit

struct GroundingMediaView: View {
    let mediaType: GroundingMediaType
    let mediaRef: String?
    let videoSound: Bool
    var onAddMedia: () -> Void
    var showTourButton: Bool = false
    var onStartTour: (() -> Void)? = nil

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?
    @State private var imageScale: CGFloat = 1.0
    @State private var imageOffset: CGSize = .zero

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.background

            switch mediaType {
            case .photo:
                photoView
            case .video:
                videoView
            case .text:
                textView
            case .none:
                placeholderView
            }

            if showTourButton, let onStartTour {
                Button(action: onStartTour) {
                    Text("Take tour")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.surfaceRaised.opacity(0.87))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.borderColor, lineWidth: 1)
                        )
                }
                .padding(12)
            }
        }
        .clipped()
    }

    @ViewBuilder
    private var photoView: some View {
        if let ref = mediaRef, let url = URL(string: ref),
            FileManager.default.fileExists(atPath: url.path) {
            #if os(iOS)
            if let uiImage = UIImage(contentsOfFile: url.path) {
                GeometryReader { geo in
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .scaleEffect(imageScale)
                        .offset(imageOffset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    imageScale = value
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    imageOffset = value.translation
                                }
                        )
                        .clipped()
                        .overlay(
                            Button("Reset") {
                                imageScale = 1.0
                                imageOffset = .zero
                            }
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(), alignment: .topTrailing
                        )
                }
            } else {
                missingMediaView
            }
            #else
            missingMediaView
            #endif
        } else {
            missingMediaView
        }
    }

    @ViewBuilder
    private var videoView: some View {
        if let ref = mediaRef, let url = URL(string: ref),
           FileManager.default.fileExists(atPath: url.path) {
            VideoPlayer(player: player)
                .disabled(true)
                .onAppear { setupVideoPlayer(url: url) }
                .onDisappear { teardownVideoPlayer() }
        } else {
            missingMediaView
        }
    }

    private var textView: some View {
        ZStack {
            Color.groundingBackground
            if let ref = mediaRef, !ref.isEmpty {
                Text(ref)
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(.accentWarm)
                    .multilineTextAlignment(.center)
                    .padding(32)
            }
        }
    }

    private var placeholderView: some View {
        Button(action: onAddMedia) {
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 36))
                    .foregroundColor(.textSecondary.opacity(0.5))
                Text("Add something that grounds you")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.textSecondary.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var missingMediaView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(.accentWarm.opacity(0.7))
            Text("Your grounding media can't be found. Would you like to choose something new?")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Choose New") { onAddMedia() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.accentCyan)
        }
    }

    private func setupVideoPlayer(url: URL) {
        let item = AVPlayerItem(url: url)
        let q = AVQueuePlayer()
        looper = AVPlayerLooper(player: q, templateItem: item)
        player = q
        if !videoSound { q.isMuted = true }
        q.play()
    }

    private func teardownVideoPlayer() {
        player?.pause()
        looper = nil
        player = nil
    }
}

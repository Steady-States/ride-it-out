import SwiftUI
import AVKit

struct GroundingMediaView: View {
    let mediaType: GroundingMediaType
    let mediaRef: String?
    let videoSound: Bool
    var transformScale: CGFloat = 1.0
    var transformOffsetFraction: CGSize = .zero
    var onAddMedia: () -> Void
    var showTourButton: Bool = false
    var onStartTour: (() -> Void)? = nil

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.background

            switch mediaType {
            case .photo:
                washed { photoView }
            case .video:
                washed { videoView }
            case .text:
                textView
            case .none:
                placeholderView
            }

            if showTourButton, let onStartTour {
                Button(action: onStartTour) {
                    Text("Take the tour")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 7)
                        .background(Color.scrim)
                        .clipShape(Capsule())
                }
                .padding(14)
            }
        }
        .clipped()
    }

    /// Saturation 0.62 / contrast 0.92 wash plus the mediaWash overlay — the
    /// treatment that keeps grounding photos from shouting over the rest of the screen.
    @ViewBuilder
    private func washed<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        content()
            .saturation(0.62)
            .contrast(0.92)
            .overlay(Color.mediaWash)
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
                        .scaleEffect(transformScale)
                        .offset(
                            x: transformOffsetFraction.width * geo.size.width,
                            y: transformOffsetFraction.height * geo.size.height
                        )
                        .clipped()
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
            GeometryReader { geo in
                VideoPlayer(player: player)
                    .disabled(true)
                    .scaleEffect(transformScale)
                    .offset(
                        x: transformOffsetFraction.width * geo.size.width,
                        y: transformOffsetFraction.height * geo.size.height
                    )
                    .clipped()
                    .onAppear { setupVideoPlayer(url: url) }
                    .onDisappear { teardownVideoPlayer() }
            }
        } else {
            missingMediaView
        }
    }

    private var textView: some View {
        ZStack(alignment: .bottomLeading) {
            Color.surface
            if let ref = mediaRef, !ref.isEmpty {
                Text(ref)
                    .font(.system(size: 23, weight: .regular))
                    .foregroundColor(.textPrimary)
                    .lineSpacing(23 * 0.35)
                    .multilineTextAlignment(.leading)
                    .padding(24)
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
                .foregroundColor(.accent.opacity(0.7))
            Text("Your grounding media can't be found. Would you like to choose something new?")
                .font(.system(size: 14))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Choose New") { onAddMedia() }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.accentText)
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

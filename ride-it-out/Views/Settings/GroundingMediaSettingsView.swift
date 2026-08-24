import SwiftUI
import UniformTypeIdentifiers
import AVKit
#if os(iOS)
import PhotosUI
#endif

struct GroundingMediaSettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @State private var selectedSource: GroundingMediaType = .none
    @State private var showFilePicker = false
    @State private var textContent: String = ""
    #if os(iOS)
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var showPhotoPicker = false
    #endif

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your anchor")
                    .font(.displaySerif(size: 30))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 22)
                    .padding(.top, 10)

                Text("One thing that pulls you back. A face, a place, or a sentence you need to hear.")
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 22)
                    .padding(.top, 4)
                    .padding(.bottom, 13)

                SectionLabel("MEDIA TYPE")
                SegmentedPicker(
                    options: GroundingMediaType.allCases,
                    selection: Binding(
                        get: { selectedSource },
                        set: { newValue in
                            selectedSource = newValue
                            #if os(iOS)
                            if newValue == .photo { showPhotoPicker = true }
                            #endif
                            if newValue == .video { showFilePicker = true }
                        }
                    ),
                    label: \.segmentLabel
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 9)

                if selectedSource == .photo || selectedSource == .video {
                    SectionLabel("PLACEMENT")
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pinch to scale, drag to move. This is how it will appear in your grounding zone.")
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)

                            if let ref = settingsVM.groundingMediaRef, !ref.isEmpty {
                                MediaPlacementEditor(settingsVM: settingsVM, mediaType: selectedSource)
                            } else {
                                Text("Choose a photo or video to position it.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textTertiary)
                            }

                            HStack {
                                Button("Reset placement") {
                                    settingsVM.saveGroundingMediaTransform(scale: 1, offsetXFraction: 0, offsetYFraction: 0)
                                }
                                .foregroundColor(.accentText)
                                .font(.system(size: 13, weight: .medium))

                                Spacer()

                                Button {
                                    #if os(iOS)
                                    if selectedSource == .photo {
                                        showPhotoPicker = true
                                    } else {
                                        showFilePicker = true
                                    }
                                    #else
                                    showFilePicker = true
                                    #endif
                                } label: {
                                    Text("Change")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.accentText)
                                        .padding(.horizontal, 16)
                                        .frame(height: 32)
                                        .background(Color.accentFill)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                    }

                    if selectedSource == .video {
                        SectionLabel("VIDEO OPTIONS")
                        SettingsCard {
                            Toggle("Play video sound", isOn: Binding(
                                get: { settingsVM.groundingVideoSound },
                                set: { settingsVM.saveGroundingVideoSound($0) }
                            ))
                            .tint(.accent)
                            .foregroundColor(.textPrimary)
                            .font(.system(size: 14, weight: .medium))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                        }
                    }
                }

                if selectedSource == .text {
                    SectionLabel("YOUR TEXT")
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 8) {
                            TextEditor(text: $textContent)
                                .frame(minHeight: 100)
                                .scrollContentBackground(.hidden)
                                .foregroundColor(.textPrimary)
                                .onChange(of: textContent) { _, newVal in
                                    if newVal.count > 200 { textContent = String(newVal.prefix(200)) }
                                }

                            Text("\(textContent.count)/200")
                                .font(.system(size: 11))
                                .foregroundColor(.textTertiary)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                            Button("Save Text") {
                                settingsVM.saveGroundingMedia(type: .text, ref: textContent)
                            }
                            .foregroundColor(.accentText)
                            .font(.system(size: 14, weight: .medium))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                    }
                }
            }
            .padding(.top, 12)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedSource = settingsVM.groundingMediaType
            if settingsVM.groundingMediaType == .text {
                textContent = settingsVM.groundingMediaRef ?? ""
            }
        }
        #if os(iOS)
        .photosPicker(isPresented: $showPhotoPicker, selection: $photoPickerItem, matching: .any(of: [.images, .videos]))
        .onChange(of: photoPickerItem) { _, item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "jpg"
                    let isVideo = item.supportedContentTypes.contains(where: { $0.conforms(to: .movie) })
                    let url = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString)
                        .appendingPathExtension(ext)
                    try? data.write(to: url)
                    await MainActor.run {
                        settingsVM.saveGroundingMedia(type: isVideo ? .video : .photo, ref: url.absoluteString)
                        selectedSource = isVideo ? .video : .photo
                    }
                }
            }
        }
        #endif
        .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.movie, .mpeg4Movie, .video]) { result in
            if let url = try? result.get() {
                settingsVM.saveGroundingMedia(type: .video, ref: url.absoluteString)
                selectedSource = .video
            }
        }
    }
}

// MARK: - Placement editor

private struct MediaPlacementEditor: View {
    @ObservedObject var settingsVM: SettingsViewModel
    let mediaType: GroundingMediaType

    @State private var scale: CGFloat = 1.0
    @State private var offsetFraction: CGSize = .zero
    @State private var gestureScale: CGFloat = 1.0
    @State private var gestureOffset: CGSize = .zero

    @State private var player: AVQueuePlayer?
    @State private var looper: AVPlayerLooper?

    private let boxAspectRatio: CGFloat = 390.0 / 422.0

    var body: some View {
        GeometryReader { geo in
            let boxSize = geo.size
            ZStack {
                Color.background

                mediaContent
                    .saturation(0.62)
                    .contrast(0.92)
                    .scaleEffect(scale * gestureScale)
                    .offset(
                        x: (offsetFraction.width + gestureOffset.width) * boxSize.width,
                        y: (offsetFraction.height + gestureOffset.height) * boxSize.height
                    )
                    .frame(width: boxSize.width, height: boxSize.height)
                    .clipped()
                    .overlay(Color.mediaWash)

                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                    .foregroundColor(.onMedia.opacity(0.5))
            }
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .onChanged { value in gestureScale = value }
                        .onEnded { value in
                            scale = min(max(scale * value, 0.5), 4)
                            gestureScale = 1.0
                            persist()
                        },
                    DragGesture()
                        .onChanged { value in
                            gestureOffset = CGSize(
                                width: value.translation.width / boxSize.width,
                                height: value.translation.height / boxSize.height
                            )
                        }
                        .onEnded { value in
                            offsetFraction.width += value.translation.width / boxSize.width
                            offsetFraction.height += value.translation.height / boxSize.height
                            gestureOffset = .zero
                            persist()
                        }
                )
            )
        }
        .aspectRatio(boxAspectRatio, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onAppear {
            scale = settingsVM.groundingMediaScale
            offsetFraction = CGSize(
                width: settingsVM.groundingMediaOffsetXFraction,
                height: settingsVM.groundingMediaOffsetYFraction
            )
        }
    }

    @ViewBuilder
    private var mediaContent: some View {
        if mediaType == .video {
            videoContent
        } else {
            photoContent
        }
    }

    @ViewBuilder
    private var photoContent: some View {
        #if os(iOS)
        if let ref = settingsVM.groundingMediaRef, let url = URL(string: ref),
           FileManager.default.fileExists(atPath: url.path),
           let uiImage = UIImage(contentsOfFile: url.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Color.clear
        }
        #else
        Color.clear
        #endif
    }

    @ViewBuilder
    private var videoContent: some View {
        if player != nil {
            VideoPlayer(player: player)
                .disabled(true)
                .onDisappear { teardown() }
        } else {
            Color.clear.onAppear { setup() }
        }
    }

    private func setup() {
        guard let ref = settingsVM.groundingMediaRef, let url = URL(string: ref),
              FileManager.default.fileExists(atPath: url.path) else { return }
        let item = AVPlayerItem(url: url)
        let queue = AVQueuePlayer()
        looper = AVPlayerLooper(player: queue, templateItem: item)
        player = queue
        queue.isMuted = true
        queue.play()
    }

    private func teardown() {
        player?.pause()
        looper = nil
        player = nil
    }

    private func persist() {
        settingsVM.saveGroundingMediaTransform(
            scale: scale,
            offsetXFraction: offsetFraction.width,
            offsetYFraction: offsetFraction.height
        )
    }
}

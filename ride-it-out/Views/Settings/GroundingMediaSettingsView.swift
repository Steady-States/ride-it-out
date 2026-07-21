import SwiftUI
import UniformTypeIdentifiers
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
        List {
            Section("Media Type") {
                Picker("Source", selection: $selectedSource) {
                    Text("Photo / Video").tag(GroundingMediaType.photo)
                    Text("Video File").tag(GroundingMediaType.video)
                    Text("Text").tag(GroundingMediaType.text)
                    Text("None").tag(GroundingMediaType.none)
                }
                .pickerStyle(.segmented)
                .onChange(of: selectedSource) { _, newValue in
                    #if os(iOS)
                    if newValue == .photo { showPhotoPicker = true }
                    #endif
                    if newValue == .video { showFilePicker = true }
                }
                .padding(.vertical, 4)
            }

            if selectedSource == .text {
                Section("Your Text") {
                    TextEditor(text: $textContent)
                        .frame(minHeight: 100)
                        .onChange(of: textContent) { _, newVal in
                            if newVal.count > 200 { textContent = String(newVal.prefix(200)) }
                        }
                    Text("\(textContent.count)/200")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .trailing)

                    Button("Save Text") {
                        settingsVM.saveGroundingMedia(type: .text, ref: textContent)
                    }
                    .foregroundColor(.accentCyan)
                }
            }

            if selectedSource == .video {
                Section("Video Options") {
                    Toggle("Play video sound", isOn: Binding(
                        get: { settingsVM.groundingVideoSound },
                        set: { settingsVM.saveGroundingVideoSound($0) }
                    ))
                    .tint(.accentCyan)
                }
            }

            if let ref = settingsVM.groundingMediaRef, !ref.isEmpty {
                Section("Current Selection") {
                    HStack {
                        Image(systemName: mediaIcon(settingsVM.groundingMediaType))
                            .foregroundColor(.accentCyan)
                        Text(previewLabel(ref, type: settingsVM.groundingMediaType))
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                            .lineLimit(2)
                        Spacer()
                        Button("Change") {
                            #if os(iOS)
                            if settingsVM.groundingMediaType == .photo {
                                showPhotoPicker = true
                            } else {
                                showFilePicker = true
                            }
                            #else
                            showFilePicker = true
                            #endif
                        }
                        .foregroundColor(.accentCyan)
                        .font(.system(size: 14))
                    }
                }
            }
        }
        .navigationTitle("Grounding Media")
        .preferredColorScheme(.dark)
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

    private func mediaIcon(_ type: GroundingMediaType) -> String {
        switch type {
        case .photo: return "photo"
        case .video: return "video"
        case .text: return "text.quote"
        case .none: return "questionmark"
        }
    }

    private func previewLabel(_ ref: String, type: GroundingMediaType) -> String {
        if type == .text { return String(ref.prefix(60)) + (ref.count > 60 ? "…" : "") }
        return URL(string: ref)?.lastPathComponent ?? ref
    }
}

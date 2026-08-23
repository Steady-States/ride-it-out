import SwiftUI
import Contacts
import ContactsUI
import UniformTypeIdentifiers

struct CustomizeLifelinesView: View {
    @ObservedObject var vm: LifelinesViewModel
    @State private var editingLifeline: Lifeline?
    @State private var showAddSheet = false
    @State private var draggedLifeline: Lifeline?
    @Environment(\.openURL) private var openURL

    private let maxLifelines = 4

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SectionLabel("LIFELINES")
                SettingsCard {
                    ForEach(Array(vm.lifelines.enumerated()), id: \.element.id) { index, lifeline in
                        row(for: lifeline, index: index)
                        if index < vm.lifelines.count - 1 {
                            Divider().background(Color.borderColor)
                        }
                    }
                }

                Text("The top lifeline is #1 and appears first on the home screen. Drag the handle to reorder, tap a lifeline to edit it, or use the call/text icons to reach out right away.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                if vm.lifelines.count < maxLifelines {
                    SettingsCard {
                        Button {
                            showAddSheet = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 18))
                                    .foregroundColor(.accentCyan)
                                    .frame(width: 22)
                                Text("Add Lifeline")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.accentCyan)
                                Spacer()
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 9)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 12)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Lifelines")
        .preferredColorScheme(.dark)
        .sheet(item: $editingLifeline) { lifeline in
            NavigationStack {
                LifelineEditView(vm: vm, originalLifeline: lifeline)
            }
        }
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                LifelineEditView(vm: vm, originalLifeline: nil)
            }
        }
    }

    @ViewBuilder
    private func row(for lifeline: Lifeline, index: Int) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textTertiary)
                .frame(width: 20)

            Button {
                editingLifeline = lifeline
            } label: {
                HStack(spacing: 10) {
                    Text("#\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.textTertiary)
                        .frame(width: 18, alignment: .leading)

                    LifelineAvatar(lifeline: lifeline, size: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(lifeline.name.isEmpty ? lifeline.phone : lifeline.name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        if !lifeline.name.isEmpty && !lifeline.phone.isEmpty {
                            Text(lifeline.phone)
                                .font(.system(size: 12))
                                .foregroundColor(.textSecondary)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
            .buttonStyle(.plain)

            if !lifeline.sanitizedPhone.isEmpty {
                Button {
                    if let url = lifeline.callURL { openURL(url) }
                } label: {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.accentCyan)
                        .frame(width: 30, height: 30)
                }
                Button {
                    if let url = lifeline.textURL { openURL(url) }
                } label: {
                    Image(systemName: "message.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.accentCyan)
                        .frame(width: 30, height: 30)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onDrag {
            draggedLifeline = lifeline
            return NSItemProvider(object: lifeline.id.uuidString as NSString)
        }
        .onDrop(
            of: [.text],
            delegate: LifelineDropDelegate(item: lifeline, vm: vm, draggedLifeline: $draggedLifeline)
        )
    }
}

// MARK: - Drag to reorder

private struct LifelineDropDelegate: DropDelegate {
    let item: Lifeline
    let vm: LifelinesViewModel
    @Binding var draggedLifeline: Lifeline?

    func dropEntered(info: DropInfo) {
        guard let draggedLifeline, draggedLifeline.id != item.id,
              let targetIndex = vm.lifelines.firstIndex(where: { $0.id == item.id }) else { return }
        withAnimation {
            vm.move(draggedLifeline, to: targetIndex)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info: DropInfo) -> Bool {
        draggedLifeline = nil
        return true
    }
}

// MARK: - Shared avatar

struct LifelineAvatar: View {
    let lifeline: Lifeline
    var size: CGFloat = 36

    var body: some View {
        Group {
            if let data = lifeline.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Color.lifeline)
                    .overlay(
                        Text(initials)
                            .font(.system(size: size * 0.36, weight: .bold))
                            .foregroundColor(.textPrimary)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initials: String {
        let source = lifeline.name.isEmpty ? lifeline.phone : lifeline.name
        let words = source.split(separator: " ").filter { $0.first?.isLetter == true }
        let result = String(words.prefix(2).compactMap(\.first)).uppercased()
        return result.isEmpty ? "#" : result
    }
}

// MARK: - Add / edit sheet

private struct LifelineEditView: View {
    @ObservedObject var vm: LifelinesViewModel
    let originalLifeline: Lifeline?

    private enum AvatarMode: String, CaseIterable, Identifiable {
        case initials = "Initials"
        case photo = "Photo"
        var id: String { rawValue }
    }

    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var phone: String
    @State private var photoData: Data?
    @State private var avatarMode: AvatarMode

    @State private var showContactPicker = false
    @State private var showContactsExplanation = false
    @State private var showPermissionDenied = false

    init(vm: LifelinesViewModel, originalLifeline: Lifeline?) {
        self.vm = vm
        self.originalLifeline = originalLifeline
        _name = State(initialValue: originalLifeline?.name ?? "")
        _phone = State(initialValue: originalLifeline?.phone ?? "")
        _photoData = State(initialValue: originalLifeline?.photoData)
        _avatarMode = State(initialValue: originalLifeline?.photoData != nil ? .photo : .initials)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    LifelineAvatar(
                        lifeline: Lifeline(name: name, phone: phone, photoData: photoData),
                        size: 72
                    )
                    Spacer()
                }
                .listRowBackground(Color.clear)
            }

            Section {
                TextField("Name", text: $name)
                    .foregroundColor(.textPrimary)
                TextField("Phone", text: $phone)
                    #if os(iOS)
                    .keyboardType(.phonePad)
                    #endif
                    .foregroundColor(.textPrimary)
            }

            Section {
                Picker("Avatar", selection: $avatarMode) {
                    ForEach(AvatarMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: avatarMode) { _, newValue in
                    if newValue == .initials { photoData = nil }
                }

                if avatarMode == .photo {
                    Button("Choose from Contacts") {
                        requestContactsAccess()
                    }
                    .foregroundColor(.accentCyan)

                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            photoData = nil
                        }
                    }
                } else {
                    Text("This lifeline will show as initials or a number, not a photo.")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            } header: {
                Text("Avatar")
            }

            if originalLifeline != nil {
                Section {
                    Button("Delete Lifeline", role: .destructive) {
                        if let originalLifeline { vm.remove(originalLifeline) }
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle(originalLifeline == nil ? "Add Lifeline" : "Edit Lifeline")
        .preferredColorScheme(.dark)
        .onAppear {
            if originalLifeline == nil {
                requestContactsAccess()
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(
                        name.trimmingCharacters(in: .whitespaces).isEmpty &&
                        phone.trimmingCharacters(in: .whitespaces).isEmpty
                    )
            }
        }
        .sheet(isPresented: $showContactPicker) {
            ContactPicker { contact in
                if let details = ContactsService.fetchContact(withIdentifier: contact.identifier) {
                    if !details.name.isEmpty { name = details.name }
                    if !details.phone.isEmpty { phone = details.phone }
                    photoData = details.imageData
                    if details.imageData != nil { avatarMode = .photo }
                }
            }
        }
        .sheet(isPresented: $showContactsExplanation) {
            contactsExplanationSheet
        }
        .alert("Contacts Access Denied", isPresented: $showPermissionDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No problem. You can add a lifeline manually by entering a name and phone number, or grant access later in your device Settings.")
        }
    }

    private var contactsExplanationSheet: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 48))
                .foregroundColor(.accentCyan)
            Text("Access Your Contacts")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            Text("To add a lifeline contact, Ride It Out needs permission to access your contacts. Your contacts are never uploaded or shared — they stay on your device.")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Allow Access") {
                showContactsExplanation = false
                ContactsService.requestAccess { granted in
                    if granted {
                        showContactPicker = true
                    } else {
                        showPermissionDenied = true
                    }
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.background)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.accentCyan)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Button("Not Now") { showContactsExplanation = false }
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .background(Color.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private func requestContactsAccess() {
        switch ContactsService.authorizationStatus() {
        case .authorized, .limited: showContactPicker = true
        case .denied, .restricted: showPermissionDenied = true
        default: showContactsExplanation = true
        }
    }

    private func save() {
        var lifeline = originalLifeline ?? Lifeline(name: name, phone: phone)
        lifeline.name = name
        lifeline.phone = phone
        lifeline.photoData = avatarMode == .photo ? photoData : nil
        vm.addOrUpdate(lifeline)
        dismiss()
    }
}

// MARK: - Native contact picker

private struct ContactPicker: UIViewControllerRepresentable {
    var onSelect: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (CNContact) -> Void
        init(onSelect: @escaping (CNContact) -> Void) { self.onSelect = onSelect }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}

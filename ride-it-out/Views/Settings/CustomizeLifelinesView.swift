import SwiftUI
import Contacts

struct CustomizeLifelinesView: View {
    @ObservedObject var vm: LifelinesViewModel
    @State private var showContactsExplanation = false
    @State private var showPermissionDenied = false
    @State private var clearSlot: Int? = nil
    @State private var showClearConfirm = false

    @State private var name1 = ""; @State private var phone1 = ""
    @State private var name2 = ""; @State private var phone2 = ""
    @State private var name3 = ""; @State private var phone3 = ""
    @State private var name4 = ""; @State private var phone4 = ""

    var body: some View {
        List {
            Section {
                Picker("Display as", selection: Binding(
                    get: { vm.displayMode },
                    set: { vm.setDisplayMode($0) }
                )) {
                    Text("Name").tag(LifelineDisplayMode.name)
                    Text("Photo").tag(LifelineDisplayMode.photo)
                }
                .pickerStyle(.segmented)
            } header: { Text("Display Mode") }

            lifelineSection(slot: 1, name: $name1, phone: $phone1, lifeline: vm.lifeline1)
            lifelineSection(slot: 2, name: $name2, phone: $phone2, lifeline: vm.lifeline2)
            lifelineSection(slot: 3, name: $name3, phone: $phone3, lifeline: vm.lifeline3)
            lifelineSection(slot: 4, name: $name4, phone: $phone4, lifeline: vm.lifeline4)
        }
        .navigationTitle("Lifelines")
        .preferredColorScheme(.dark)
        .onAppear { populateFields() }
        .confirmationDialog("Remove this lifeline?", isPresented: $showClearConfirm, titleVisibility: .visible) {
            Button("Remove", role: .destructive) {
                if let slot = clearSlot { vm.clear(slot: slot); populateFields() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showContactsExplanation) {
            contactsExplanationSheet
        }
        .alert("Contacts Access Denied", isPresented: $showPermissionDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("No problem. You can add contacts manually by entering a name and phone number, or grant access later in your device Settings.")
        }
    }

    @ViewBuilder
    private func lifelineSection(slot: Int, name: Binding<String>, phone: Binding<String>, lifeline: Lifeline?) -> some View {
        Section(header: Text("Lifeline \(slot)")) {
            TextField("Name", text: name)
                .foregroundColor(.textPrimary)
            TextField("Phone", text: phone)
                #if os(iOS)
                .keyboardType(.phonePad)
                #endif
                .foregroundColor(.textPrimary)

            HStack {
                Button("Choose Contact") {
                    requestContactsAccess()
                }
                .foregroundColor(.accentCyan)
                .font(.system(size: 14))

                Spacer()

                Button {
                    let n = name.wrappedValue
                    let p = phone.wrappedValue
                    guard !n.isEmpty || !p.isEmpty else { return }
                    vm.save(lifeline: Lifeline(name: n, phone: p), slot: slot)
                } label: {
                    Text("Save")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.background)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color.accentCyan)
                        .clipShape(Capsule())
                }

                if lifeline != nil {
                    Button("Clear") {
                        clearSlot = slot
                        showClearConfirm = true
                    }
                    .foregroundColor(.destructiveRed)
                    .font(.system(size: 14))
                }
            }
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
                    if !granted { showPermissionDenied = true }
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
        let status = ContactsService.authorizationStatus()
        switch status {
        case .authorized, .limited: break
        case .denied, .restricted: showPermissionDenied = true
        default: showContactsExplanation = true
        }
    }

    private func populateFields() {
        name1 = vm.lifeline1?.name ?? ""; phone1 = vm.lifeline1?.phone ?? ""
        name2 = vm.lifeline2?.name ?? ""; phone2 = vm.lifeline2?.phone ?? ""
        name3 = vm.lifeline3?.name ?? ""; phone3 = vm.lifeline3?.phone ?? ""
        name4 = vm.lifeline4?.name ?? ""; phone4 = vm.lifeline4?.phone ?? ""
    }
}

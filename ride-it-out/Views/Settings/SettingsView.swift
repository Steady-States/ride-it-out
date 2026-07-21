import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var lifelinesVM: LifelinesViewModel

    @State private var showResetStep1 = false
    @State private var showResetStep2 = false
    @State private var showMailError = false
    @State private var showMailCopied = false
    @AppStorage("rideItOut_onboardingComplete") private var onboardingComplete: Bool = true
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                NavigationLink("Customize Breathing") {
                    CustomizeBreathingView(
                        settingsVM: settingsVM,
                        breathingVM: BreathingViewModel()
                    )
                }
            } header: { Text("1. Breathing") }

            Section {
                NavigationLink("Grounding Media") {
                    GroundingMediaSettingsView(settingsVM: settingsVM)
                }
            } header: { Text("2. Grounding") }

            Section {
                NavigationLink("Customize Lifelines") {
                    CustomizeLifelinesView(vm: lifelinesVM)
                }
            } header: { Text("3. Lifelines") }

            Section {
                NavigationLink("Reminders") {
                    RemindersView(settingsVM: settingsVM)
                }
            } header: { Text("4. Reminders") }

            Section {
                NavigationLink("Welcome Screen") {
                    WelcomeView()
                }
            } header: { Text("5. Onboarding") }

            Section {
                Button("Reset Data", role: .destructive) {
                    showResetStep1 = true
                }
            } header: { Text("6. Reset") }

            Section {
                // Phase 2: StoreKit in-app purchase (com.steadystates.rideitout.support)
                Button("Support Ride It Out") {}
                    .foregroundColor(.accentCyan)
            } header: { Text("7. Support") }

            Section {
                Button("Feedback & Suggestions") {
                    openFeedbackMail()
                }
                .foregroundColor(.accentCyan)
            } header: { Text("8. Feedback") }

            Section {
                Button("Discord Community") {
                    if let url = URL(string: "https://discord.gg/YOUR_INVITE") {
                        openURL(url)
                    }
                }
                .foregroundColor(.accentCyan)
            } header: { Text("9. Discord") }

            Section {
                NavigationLink("Privacy & Data") {
                    PrivacyView()
                }
                Text("Add the Ride It Out widget to your home screen or lock screen for instant access. Long press your home screen and tap the + button to get started.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
            } header: { Text("10. Privacy & Widgets") }
        }
        .navigationTitle("Settings")
        .preferredColorScheme(.dark)
        .alert("Reset Everything?", isPresented: $showResetStep1) {
            Button("Reset Everything", role: .destructive) { showResetStep2 = true }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will erase all your settings, contacts, and grounding media. Ride It Out will return to its default state. This cannot be undone.")
        }
        .alert("Are you sure?", isPresented: $showResetStep2) {
            Button("Yes, Reset", role: .destructive) { performReset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
        .alert("No mail app found", isPresented: $showMailError) {
            Button("Copy Email") {
                #if os(iOS)
                UIPasteboard.general.string = "feedback@steadystates.org"
                #endif
                showMailCopied = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can reach us at feedback@steadystates.org")
        }
        .overlay(alignment: .bottom) {
            if showMailCopied {
                Text("Copied to clipboard")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.background)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accentCyan)
                    .clipShape(Capsule())
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation { showMailCopied = false }
                        }
                    }
            }
        }
        .animation(.easeInOut, value: showMailCopied)
    }

    private func openFeedbackMail() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let subject = "Ride It Out Feedback"
        let body = "App Version: \(appVersion)\n\nYour feedback:\n"
        let encoded = "mailto:feedback@steadystates.org?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        if let url = URL(string: encoded) {
            openURL(url) { accepted in
                if !accepted { showMailError = true }
            }
        }
    }

    private func performReset() {
        KeychainService.deleteAll()
        StorageKey.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        onboardingComplete = false
    }
}

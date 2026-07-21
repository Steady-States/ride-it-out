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
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)

                SectionLabel("CUSTOMIZE")
                SettingsCard {
                    NavigationLink {
                        CustomizeBreathingView(
                            settingsVM: settingsVM,
                            breathingVM: BreathingViewModel()
                        )
                    } label: {
                        SettingsLinkRow(icon: "wind", title: "Customize Breathing")
                    }
                    Divider().background(Color.borderColor)
                    NavigationLink {
                        GroundingMediaSettingsView(settingsVM: settingsVM)
                    } label: {
                        SettingsLinkRow(icon: "photo.on.rectangle.angled", title: "Grounding Media")
                    }
                    Divider().background(Color.borderColor)
                    NavigationLink {
                        CustomizeLifelinesView(vm: lifelinesVM)
                    } label: {
                        SettingsLinkRow(icon: "person.2.fill", title: "Customize Lifelines")
                    }
                }

                SectionLabel("REMINDERS")
                SettingsCard {
                    NavigationLink {
                        RemindersView(settingsVM: settingsVM)
                    } label: {
                        SettingsLinkRow(icon: "bell.badge", title: "Reminders")
                    }
                }

                SectionLabel("HELP")
                SettingsCard {
                    NavigationLink {
                        WelcomeView()
                    } label: {
                        SettingsLinkRow(icon: "play.circle", title: "View Welcome Screens")
                    }
                    Divider().background(Color.borderColor)
                    Button {
                        openFeedbackMail()
                    } label: {
                        SettingsLinkRow(
                            icon: "envelope",
                            title: "Send Feedback",
                            subtitle: "Feedback is always welcome!"
                        )
                    }
                    Divider().background(Color.borderColor)
                    Button {
                        if let url = URL(string: "https://discord.gg/YOUR_INVITE") {
                            openURL(url)
                        }
                    } label: {
                        SettingsLinkRow(
                            icon: "bubble.left.and.bubble.right.fill",
                            title: "Join our Discord",
                            subtitle: "Community, support & updates"
                        )
                    }
                }

                SectionLabel("DATA")
                SettingsCard {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        SettingsLinkRow(icon: "lock.fill", title: "Privacy & Data")
                    }
                    Divider().background(Color.borderColor)
                    Button {
                        showResetStep1 = true
                    } label: {
                        SettingsLinkRow(icon: "trash", title: "Reset all data", tint: .destructiveRed)
                    }
                }

                Text("Add the Ride It Out widget to your home screen or lock screen for instant access. Long press your home screen and tap the + button to get started.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 8)

                SectionLabel("SUPPORT")
                VStack(alignment: .leading, spacing: 8) {
                    Text("This app will always be fully-functional, free, and private. Support development with an optional one-time tip.")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)

                    // Phase 2: StoreKit in-app purchase (com.steadystates.rideitout.support)
                    Button("Support Ride It Out") {}
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.background)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 36)
                        .background(Color.accentCyan)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding(10)
                .background(Color.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 12)
                .padding(.bottom, 8)

                VStack(spacing: 2) {
                    Text("Ride It Out \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(.system(size: 11))
                        .foregroundColor(.textTertiary)
                    Text("© 2026 Steady States")
                        .font(.system(size: 11))
                        .foregroundColor(.textTertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
        KeychainKey.allCases.forEach {
            KeychainService.delete(forKey: $0)
        }
        StorageKey.allCases.forEach {
            UserDefaults.standard.removeObject(forKey: $0.rawValue)
        }
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        onboardingComplete = false
    }
}

private struct SectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .tracking(1)
            .foregroundColor(.textTertiary)
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
    }
}

private struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

private struct SettingsLinkRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: Color = .accentCyan

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(tint)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(tint)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.forward")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(tint == .destructiveRed ? tint : .textTertiary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .contentShape(Rectangle())
    }
}

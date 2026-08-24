import SwiftUI
import UserNotifications

struct SettingsView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @ObservedObject var lifelinesVM: LifelinesViewModel
    var onStartTour: () -> Void

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
                    .font(.displaySerif(size: 34))
                    .foregroundColor(.textPrimary)
                    .padding(.horizontal, 22)
                    .padding(.top, 10)
                    .padding(.bottom, 8)

                SectionLabel("APPEARANCE")
                SegmentedPicker(
                    options: Appearance.allCases,
                    selection: Binding(
                        get: { settingsVM.appearance },
                        set: { settingsVM.saveAppearance($0) }
                    ),
                    label: \.label
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 13)

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
                    Button(action: onStartTour) {
                        SettingsLinkRow(icon: "play.circle", title: "Guided Tour", tint: .sage)
                    }
                    Divider().background(Color.borderColor)
                    Button {
                        openFeedbackMail()
                    } label: {
                        SettingsLinkRow(
                            icon: "envelope",
                            title: "Send Feedback",
                            subtitle: "Feedback is always welcome",
                            tint: .sage
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
                            subtitle: "Community, support and updates",
                            tint: .sage
                        )
                    }
                }

                SectionLabel("DATA")
                SettingsCard {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        SettingsLinkRow(icon: "lock.fill", title: "Privacy and data")
                    }
                    Divider().background(Color.borderColor)
                    Button {
                        showResetStep1 = true
                    } label: {
                        SettingsLinkRow(icon: "trash", title: "Erase everything", tint: .destructive, showChevron: false)
                    }
                }

                Text("Add the Ride It Out widget to your home screen or lock screen for instant access. Long press your home screen and tap the + button to get started.")
                    .font(.system(size: 12))
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 9)

                SectionLabel("SUPPORT")
                HStack(spacing: 12) {
                    Text("Free, complete and private. Always.")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)

                    Spacer(minLength: 8)

                    // Phase 2: StoreKit in-app purchase (com.steadystates.rideitout.support)
                    Button("Leave a tip") {}
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.sageOn)
                        .padding(.horizontal, 16)
                        .frame(height: 34)
                        .background(Color.sageDeep)
                        .clipShape(Capsule())
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color.sageFill)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 14)
                .padding(.bottom, 9)

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
                    .foregroundColor(.accentOn)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.accent)
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

struct SectionLabel: View {
    let title: String
    init(_ title: String) { self.title = title }

    var body: some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .tracking(1.4)
            .foregroundColor(.textTertiary)
            .padding(.horizontal, 22)
            .padding(.bottom, 7)
    }
}

struct SettingsCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 14)
        .padding(.bottom, 9)
    }
}

#Preview {
    NavigationStack {
        SettingsView(settingsVM: SettingsViewModel(), lifelinesVM: LifelinesViewModel(), onStartTour: {})
    }
}

enum SettingsRowTint {
    case accent, sage, destructive

    var circleFill: Color {
        switch self {
        case .accent: return .accentFill
        case .sage: return .sageFill
        case .destructive: return .destructiveFill
        }
    }

    var iconColor: Color {
        switch self {
        case .accent: return .accentText
        case .sage: return .sageText
        case .destructive: return .destructive
        }
    }
}

struct SettingsLinkRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var tint: SettingsRowTint = .accent
    var showChevron: Bool = true

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(tint.circleFill)
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: icon)
                        .symbolRenderingMode(.monochrome)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(tint.iconColor)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(tint == .destructive ? .destructive : .textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
            }

            Spacer()

            if showChevron {
                Image(systemName: "chevron.forward")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.textTertiary)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, subtitle != nil ? 10 : 12)
        .contentShape(Rectangle())
    }
}

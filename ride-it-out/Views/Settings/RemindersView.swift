import SwiftUI
import UserNotifications

struct RemindersView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @State private var showPermissionExplanation = false
    @State private var times: [Date] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                SectionLabel("REMINDERS")
                    .padding(.bottom, 0)

                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Daily check-ins", isOn: Binding(
                        get: { settingsVM.remindersEnabled },
                        set: { newVal in toggleReminders(newVal) }
                    ))
                    .tint(.accent)
                    .foregroundColor(.textPrimary)
                    .font(.system(size: 16, weight: .medium))

                    Text("A gentle nudge to breathe before you need to. You choose when, and how often — up to three a day.")
                        .font(.system(size: 12))
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                .background(Color.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: 24))

                if settingsVM.remindersEnabled {
                    ForEach(times.indices, id: \.self) { i in
                        HStack {
                            DatePicker("", selection: $times[i], displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .tint(.accent)
                                .onChange(of: times[i]) { _, _ in saveReminders() }

                            Spacer()

                            Button {
                                times.remove(at: i)
                                saveReminders()
                            } label: {
                                Image(systemName: "minus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.destructive)
                                    .frame(width: 38, height: 38)
                                    .background(Color.destructiveFill)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.surfaceRaised)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    }

                    if times.count < 3 {
                        Button {
                            times.append(Date())
                            saveReminders()
                        } label: {
                            Text("Add a time")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.accentText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [6]))
                                .foregroundColor(.borderColor)
                        )
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
        }
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Reminders")
        .onAppear { loadTimes() }
        .sheet(isPresented: $showPermissionExplanation) {
            permissionSheet
        }
    }

    private var permissionSheet: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "bell.badge")
                .font(.system(size: 48))
                .foregroundColor(.accentText)
            Text("Enable Reminders")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.textPrimary)
            Text("Ride It Out would like to send you gentle reminders to check in. You control when and how often.")
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Allow Notifications") {
                showPermissionExplanation = false
                NotificationService.shared.requestAuthorization { granted in
                    if granted {
                        settingsVM.saveReminders(enabled: true, times: settingsVM.reminderTimes)
                    }
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(.accentOn)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.accent)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Button("Not Now") { showPermissionExplanation = false }
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .background(Color.background.ignoresSafeArea())
    }

    private func toggleReminders(_ enabled: Bool) {
        if enabled {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    if settings.authorizationStatus == .notDetermined {
                        showPermissionExplanation = true
                    } else {
                        settingsVM.saveReminders(enabled: true, times: settingsVM.reminderTimes)
                    }
                }
            }
        } else {
            settingsVM.saveReminders(enabled: false, times: settingsVM.reminderTimes)
            NotificationService.shared.removeAllReminders()
        }
    }

    private func saveReminders() {
        let components = times.map { date -> DateComponents in
            Calendar.current.dateComponents([.hour, .minute], from: date)
        }
        settingsVM.saveReminders(enabled: settingsVM.remindersEnabled, times: components)
        if settingsVM.remindersEnabled {
            NotificationService.shared.scheduleReminders(components)
        }
    }

    private func loadTimes() {
        times = settingsVM.reminderTimes.compactMap { components in
            Calendar.current.date(from: components)
        }
    }
}

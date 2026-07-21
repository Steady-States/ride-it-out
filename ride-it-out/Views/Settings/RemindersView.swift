import SwiftUI
import UserNotifications

struct RemindersView: View {
    @ObservedObject var settingsVM: SettingsViewModel
    @State private var showPermissionExplanation = false
    @State private var times: [Date] = []

    var body: some View {
        List {
            Section {
                Toggle("Daily Reminders", isOn: Binding(
                    get: { settingsVM.remindersEnabled },
                    set: { newVal in toggleReminders(newVal) }
                ))
                .tint(.accentCyan)

                if settingsVM.remindersEnabled {
                    Text("Ride It Out would like to send you gentle reminders to check in. You control when and how often.")
                        .font(.system(size: 13))
                        .foregroundColor(.textSecondary)
                }
            }

            if settingsVM.remindersEnabled {
                Section("Reminder Times") {
                    ForEach(times.indices, id: \.self) { i in
                        HStack {
                            DatePicker("", selection: $times[i], displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .onChange(of: times[i]) { _, _ in saveReminders() }
                            Spacer()
                            Button {
                                times.remove(at: i)
                                saveReminders()
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.destructiveRed)
                            }
                        }
                    }

                    if times.count < 3 {
                        Button {
                            times.append(Date())
                            saveReminders()
                        } label: {
                            Label("Add Reminder", systemImage: "plus.circle")
                                .foregroundColor(.accentCyan)
                        }
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .preferredColorScheme(.dark)
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
                .foregroundColor(.accentCyan)
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
            .foregroundColor(.background)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.accentCyan)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .padding(.horizontal, 32)
            Button("Not Now") { showPermissionExplanation = false }
                .foregroundColor(.textSecondary)
            Spacer()
        }
        .background(Color.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
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

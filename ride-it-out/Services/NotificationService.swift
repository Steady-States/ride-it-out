import UserNotifications
import Foundation

class NotificationService {

    static let shared = NotificationService()

    private let messages = [
        "Take a breath. You've got this.",
        "A moment of calm is one tap away.",
        "Check in with yourself.",
        "Your tools are ready when you need them."
    ]

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    func scheduleReminders(_ times: [DateComponents]) {
        removeAllReminders()
        times.enumerated().forEach { index, time in
            let content = UNMutableNotificationContent()
            content.title = "Ride It Out"
            content.body = messages[index % messages.count]
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
            let request = UNNotificationRequest(
                identifier: "rideitout_reminder_\(index)",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }
    }

    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

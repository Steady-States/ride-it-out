import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {

    @Published var selectedModalityID: String
    @Published var hapticsEnabled: Bool
    @Published var groundingMediaType: GroundingMediaType
    @Published var groundingMediaRef: String?
    @Published var groundingVideoSound: Bool
    @Published var remindersEnabled: Bool
    @Published var reminderTimes: [DateComponents]

    init() {
        let defaults = UserDefaults.standard
        selectedModalityID = defaults.string(forKey: StorageKey.breathingModalityID.rawValue) ?? BreathingModalities.box.id
        hapticsEnabled = defaults.object(forKey: StorageKey.hapticsEnabled.rawValue) as? Bool ?? true
        groundingVideoSound = defaults.bool(forKey: StorageKey.groundingVideoSound.rawValue)
        remindersEnabled = defaults.bool(forKey: StorageKey.remindersEnabled.rawValue)

        if let raw = defaults.string(forKey: StorageKey.groundingMediaType.rawValue),
           let type = GroundingMediaType(rawValue: raw) {
            groundingMediaType = type
        } else {
            groundingMediaType = .none
        }

        groundingMediaRef = defaults.string(forKey: StorageKey.groundingMediaRef.rawValue)

        if let data = defaults.data(forKey: StorageKey.reminderTimes.rawValue),
           let times = try? JSONDecoder().decode([DateComponents].self, from: data) {
            reminderTimes = times
        } else {
            reminderTimes = []
        }
    }

    func saveModalityID(_ id: String) {
        selectedModalityID = id
        UserDefaults.standard.set(id, forKey: StorageKey.breathingModalityID.rawValue)
    }

    func saveHapticsEnabled(_ enabled: Bool) {
        hapticsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: StorageKey.hapticsEnabled.rawValue)
    }

    func saveGroundingMedia(type: GroundingMediaType, ref: String?) {
        groundingMediaType = type
        groundingMediaRef = ref
        UserDefaults.standard.set(type.rawValue, forKey: StorageKey.groundingMediaType.rawValue)
        UserDefaults.standard.set(ref, forKey: StorageKey.groundingMediaRef.rawValue)
    }

    func saveGroundingVideoSound(_ enabled: Bool) {
        groundingVideoSound = enabled
        UserDefaults.standard.set(enabled, forKey: StorageKey.groundingVideoSound.rawValue)
    }

    func saveReminders(enabled: Bool, times: [DateComponents]) {
        remindersEnabled = enabled
        reminderTimes = times
        UserDefaults.standard.set(enabled, forKey: StorageKey.remindersEnabled.rawValue)
        if let data = try? JSONEncoder().encode(times) {
            UserDefaults.standard.set(data, forKey: StorageKey.reminderTimes.rawValue)
        }
    }

    var selectedModality: BreathingModality {
        BreathingModalities.all.first { $0.id == selectedModalityID } ?? BreathingModalities.box
    }
}

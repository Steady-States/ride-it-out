import SwiftUI
import Combine

enum Appearance: String, CaseIterable, Identifiable, Equatable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class SettingsViewModel: ObservableObject {

    @Published var appearance: Appearance
    @Published var selectedModalityID: String
    @Published var hapticsEnabled: Bool
    @Published var groundingMediaType: GroundingMediaType
    @Published var groundingMediaRef: String?
    @Published var groundingVideoSound: Bool
    @Published var groundingMediaScale: CGFloat
    @Published var groundingMediaOffsetXFraction: CGFloat
    @Published var groundingMediaOffsetYFraction: CGFloat
    @Published var remindersEnabled: Bool
    @Published var reminderTimes: [DateComponents]

    init() {
        let defaults = UserDefaults.standard
        if let raw = defaults.string(forKey: StorageKey.appearance.rawValue), let value = Appearance(rawValue: raw) {
            appearance = value
        } else {
            appearance = .system
        }
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

        let storedScale = defaults.object(forKey: StorageKey.groundingMediaScale.rawValue) as? Double
        groundingMediaScale = CGFloat(storedScale ?? 1.0)
        groundingMediaOffsetXFraction = CGFloat(defaults.double(forKey: StorageKey.groundingMediaOffsetX.rawValue))
        groundingMediaOffsetYFraction = CGFloat(defaults.double(forKey: StorageKey.groundingMediaOffsetY.rawValue))

        if let data = defaults.data(forKey: StorageKey.reminderTimes.rawValue),
           let times = try? JSONDecoder().decode([DateComponents].self, from: data) {
            reminderTimes = times
        } else {
            reminderTimes = []
        }
    }

    func saveAppearance(_ value: Appearance) {
        appearance = value
        UserDefaults.standard.set(value.rawValue, forKey: StorageKey.appearance.rawValue)
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
        saveGroundingMediaTransform(scale: 1.0, offsetXFraction: 0, offsetYFraction: 0)
    }

    func saveGroundingMediaTransform(scale: CGFloat, offsetXFraction: CGFloat, offsetYFraction: CGFloat) {
        groundingMediaScale = scale
        groundingMediaOffsetXFraction = offsetXFraction
        groundingMediaOffsetYFraction = offsetYFraction
        let defaults = UserDefaults.standard
        defaults.set(Double(scale), forKey: StorageKey.groundingMediaScale.rawValue)
        defaults.set(Double(offsetXFraction), forKey: StorageKey.groundingMediaOffsetX.rawValue)
        defaults.set(Double(offsetYFraction), forKey: StorageKey.groundingMediaOffsetY.rawValue)
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

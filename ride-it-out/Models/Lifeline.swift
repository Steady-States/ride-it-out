import Foundation

struct Lifeline: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var photoData: Data? = nil
}

extension Lifeline {
    var sanitizedPhone: String { phone.filter { $0.isNumber || $0 == "+" } }
    var callURL: URL? { URL(string: "tel://\(sanitizedPhone)") }
    var textURL: URL? { URL(string: "sms://\(sanitizedPhone)") }

    var initials: String {
        let source = name.isEmpty ? phone : name
        let words = source.split(separator: " ").filter { $0.first?.isLetter == true }
        let result = String(words.prefix(2).compactMap(\.first)).uppercased()
        return result.isEmpty ? "#" : result
    }
}

enum GroundingMediaType: String, Codable, CaseIterable, Identifiable, Equatable {
    case photo
    case video
    case text
    case none

    var id: String { rawValue }

    var segmentLabel: String {
        switch self {
        case .photo: return "Photo"
        case .video: return "Video"
        case .text: return "Words"
        case .none: return "None"
        }
    }
}

enum StorageKey: String, CaseIterable {
    case onboardingComplete      = "rideItOut_onboardingComplete"
    case breathingModalityID     = "rideItOut_breathingModalityID"
    case groundingMediaType      = "rideItOut_groundingMediaType"
    case groundingMediaRef       = "rideItOut_groundingMediaRef"
    case groundingVideoSound     = "rideItOut_groundingVideoSound"
    case groundingMediaScale     = "rideItOut_groundingMediaScale"
    case groundingMediaOffsetX   = "rideItOut_groundingMediaOffsetX"
    case groundingMediaOffsetY   = "rideItOut_groundingMediaOffsetY"
    case hapticsEnabled          = "rideItOut_hapticsEnabled"
    case remindersEnabled        = "rideItOut_remindersEnabled"
    case reminderTimes           = "rideItOut_reminderTimes"
    case appearance              = "rideItOut_appearance"
}

enum KeychainKey: String, CaseIterable {
    case lifelines = "rideItOut_lifelines"
}

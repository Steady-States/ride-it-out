import Foundation

struct Lifeline: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var phone: String
    var photoData: Data? = nil
}

enum GroundingMediaType: String, Codable {
    case photo
    case video
    case text
    case none
}

enum StorageKey: String, CaseIterable {
    case onboardingComplete      = "rideItOut_onboardingComplete"
    case breathingModalityID     = "rideItOut_breathingModalityID"
    case groundingMediaType      = "rideItOut_groundingMediaType"
    case groundingMediaRef       = "rideItOut_groundingMediaRef"
    case groundingVideoSound     = "rideItOut_groundingVideoSound"
    case hapticsEnabled          = "rideItOut_hapticsEnabled"
    case remindersEnabled        = "rideItOut_remindersEnabled"
    case reminderTimes           = "rideItOut_reminderTimes"
}

enum KeychainKey: String, CaseIterable {
    case lifelines = "rideItOut_lifelines"
}

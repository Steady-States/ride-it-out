import Foundation

struct Lifeline: Codable, Identifiable {
    var id: String { phone }
    var name: String
    var phone: String
    var hasContactPhoto: Bool = false
    var contactIdentifier: String? = nil
}

enum GroundingMediaType: String, Codable {
    case photo
    case video
    case text
    case none
}

enum LifelineDisplayMode: String {
    case name
    case photo
}

enum StorageKey: String, CaseIterable {
    case onboardingComplete      = "rideItOut_onboardingComplete"
    case breathingModalityID     = "rideItOut_breathingModalityID"
    case groundingMediaType      = "rideItOut_groundingMediaType"
    case groundingMediaRef       = "rideItOut_groundingMediaRef"
    case groundingVideoSound     = "rideItOut_groundingVideoSound"
    case lifelineDisplay         = "rideItOut_lifelineDisplay"
    case hapticsEnabled          = "rideItOut_hapticsEnabled"
    case remindersEnabled        = "rideItOut_remindersEnabled"
    case reminderTimes           = "rideItOut_reminderTimes"
}

enum KeychainKey: String, CaseIterable {
    case lifeline1 = "rideItOut_lifeline_1"
    case lifeline2 = "rideItOut_lifeline_2"
    case lifeline3 = "rideItOut_lifeline_3"
    case lifeline4 = "rideItOut_lifeline_4"
}

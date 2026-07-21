import SwiftUI
import Combine

class LifelinesViewModel: ObservableObject {

    @Published var lifeline1: Lifeline?
    @Published var lifeline2: Lifeline?
    @Published var lifeline3: Lifeline?
    @Published var lifeline4: Lifeline?

    @Published var displayMode: LifelineDisplayMode = .name

    var filledLifelines: [Lifeline] {
        [lifeline1, lifeline2, lifeline3, lifeline4].compactMap { $0 }
    }

    init() {
        load()
    }

    func load() {
        lifeline1 = KeychainService.load(forKey: .lifeline1)
        lifeline2 = KeychainService.load(forKey: .lifeline2)
        lifeline3 = KeychainService.load(forKey: .lifeline3)
        lifeline4 = KeychainService.load(forKey: .lifeline4)

        // Set defaults if empty
        if lifeline1 == nil {
            let defaultL1 = Lifeline(name: "988 Crisis Lifeline", phone: "988")
            KeychainService.save(defaultL1, forKey: .lifeline1)
            lifeline1 = defaultL1
        }
        if lifeline2 == nil {
            let defaultL2 = Lifeline(name: "Samaritans UK", phone: "116123")
            KeychainService.save(defaultL2, forKey: .lifeline2)
            lifeline2 = defaultL2
        }

        if let raw = UserDefaults.standard.string(forKey: StorageKey.lifelineDisplay.rawValue),
           let mode = LifelineDisplayMode(rawValue: raw) {
            displayMode = mode
        }
    }

    func save(lifeline: Lifeline, slot: Int) {
        let key = keychainKey(for: slot)
        KeychainService.save(lifeline, forKey: key)
        switch slot {
        case 1: lifeline1 = lifeline
        case 2: lifeline2 = lifeline
        case 3: lifeline3 = lifeline
        case 4: lifeline4 = lifeline
        default: break
        }
    }

    func clear(slot: Int) {
        KeychainService.delete(forKey: keychainKey(for: slot))
        switch slot {
        case 1: lifeline1 = nil
        case 2: lifeline2 = nil
        case 3: lifeline3 = nil
        case 4: lifeline4 = nil
        default: break
        }
    }

    func setDisplayMode(_ mode: LifelineDisplayMode) {
        displayMode = mode
        UserDefaults.standard.set(mode.rawValue, forKey: StorageKey.lifelineDisplay.rawValue)
    }

    private func keychainKey(for slot: Int) -> KeychainKey {
        switch slot {
        case 1: return .lifeline1
        case 2: return .lifeline2
        case 3: return .lifeline3
        default: return .lifeline4
        }
    }
}

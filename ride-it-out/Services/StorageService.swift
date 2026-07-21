import Security
import Foundation

class KeychainService {

    static func saveLifelines(_ lifelines: [Lifeline]) {
        guard let data = try? JSONEncoder().encode(lifelines) else { return }
        let query: [String: Any] = [
            kSecClass as String:          kSecClassGenericPassword,
            kSecAttrAccount as String:    KeychainKey.lifelines.rawValue,
            kSecValueData as String:      data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    static func loadLifelines() -> [Lifeline] {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: KeychainKey.lifelines.rawValue,
            kSecReturnData as String:  true,
            kSecMatchLimit as String:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data,
              let lifelines = try? JSONDecoder().decode([Lifeline].self, from: data) else { return [] }
        return lifelines
    }

    static func delete(forKey key: KeychainKey) {
        let query: [String: Any] = [
            kSecClass as String:       kSecClassGenericPassword,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}

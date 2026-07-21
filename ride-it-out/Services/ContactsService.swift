import Contacts
import Foundation

class ContactsService {

    static func requestAccess(completion: @escaping (Bool) -> Void) {
        CNContactStore().requestAccess(for: .contacts) { granted, _ in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static func authorizationStatus() -> CNAuthorizationStatus {
        CNContactStore.authorizationStatus(for: .contacts)
    }

    // Fetches only name and phone — never reads full contact list
    static func fetchContact(withIdentifier identifier: String) -> (name: String, phone: String)? {
        let store = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]
        guard let contact = try? store.unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch) else {
            return nil
        }
        let name = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)
        let phone = contact.phoneNumbers.first?.value.stringValue ?? ""
        return (name, phone)
    }
}

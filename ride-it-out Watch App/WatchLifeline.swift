import Foundation

struct WatchLifeline: Identifiable {
    let id = UUID()
    var name: String
    var phone: String
    var photoData: Data?
}

extension WatchLifeline {
    var sanitizedPhone: String { phone.filter { $0.isNumber || $0 == "+" } }
    var callURL: URL? { URL(string: "tel://\(sanitizedPhone)") }
    var textURL: URL? { URL(string: "sms://\(sanitizedPhone)") }
}

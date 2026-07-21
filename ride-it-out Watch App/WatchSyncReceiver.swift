import Foundation
import Combine
import WatchConnectivity

class WatchSyncReceiver: NSObject, ObservableObject, WCSessionDelegate {

    @Published var modalityID: String
    @Published var hapticsEnabled: Bool
    @Published var lifelines: [WatchLifeline]
    @Published var groundingImageData: Data?

    private enum CacheKey {
        static let modalityID = "watch_modalityID"
        static let hapticsEnabled = "watch_hapticsEnabled"
        static let lifelines = "watch_lifelines"
        static let groundingImageData = "watch_groundingImageData"
    }

    override init() {
        let defaults = UserDefaults.standard
        modalityID = defaults.string(forKey: CacheKey.modalityID) ?? BreathingModalities.box.id
        hapticsEnabled = defaults.object(forKey: CacheKey.hapticsEnabled) as? Bool ?? true
        groundingImageData = defaults.data(forKey: CacheKey.groundingImageData)
        if let cached = defaults.array(forKey: CacheKey.lifelines) as? [[String: Any]] {
            lifelines = cached.map {
                WatchLifeline(
                    name: $0["name"] as? String ?? "",
                    phone: $0["phone"] as? String ?? "",
                    photoData: $0["photoData"] as? Data
                )
            }
        } else {
            lifelines = []
        }
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        let context = session.receivedApplicationContext
        guard !context.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            self?.apply(context)
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { [weak self] in
            self?.apply(applicationContext)
        }
    }

    private func apply(_ context: [String: Any]) {
        let defaults = UserDefaults.standard

        if let modalityID = context["modalityID"] as? String {
            self.modalityID = modalityID
            defaults.set(modalityID, forKey: CacheKey.modalityID)
        }
        if let hapticsEnabled = context["hapticsEnabled"] as? Bool {
            self.hapticsEnabled = hapticsEnabled
            defaults.set(hapticsEnabled, forKey: CacheKey.hapticsEnabled)
        }
        if let rawLifelines = context["lifelines"] as? [[String: Any]] {
            lifelines = rawLifelines.map {
                WatchLifeline(
                    name: $0["name"] as? String ?? "",
                    phone: $0["phone"] as? String ?? "",
                    photoData: $0["photoData"] as? Data
                )
            }
            defaults.set(rawLifelines, forKey: CacheKey.lifelines)
        }
        if let imageData = context["groundingImageData"] as? Data {
            groundingImageData = imageData
            defaults.set(imageData, forKey: CacheKey.groundingImageData)
        } else if context.keys.contains("groundingImageData") {
            groundingImageData = nil
            defaults.removeObject(forKey: CacheKey.groundingImageData)
        }
    }
}

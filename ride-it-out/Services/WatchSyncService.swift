import Foundation
import WatchConnectivity
import UIKit

class WatchSyncService: NSObject, WCSessionDelegate {

    static let shared = WatchSyncService()

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func sync(settings: SettingsViewModel, lifelines: LifelinesViewModel) {
        guard WCSession.isSupported(), WCSession.default.activationState == .activated else { return }

        var context: [String: Any] = [
            "modalityID": settings.selectedModalityID,
            "hapticsEnabled": settings.hapticsEnabled,
            "lifelines": lifelines.lifelines.prefix(4).map { lifeline -> [String: Any] in
                var entry: [String: Any] = [
                    "name": lifeline.name,
                    "phone": lifeline.phone
                ]
                if let photoData = lifeline.photoData,
                   let resized = Self.resizedJPEGData(from: photoData, maxDimension: 120, quality: 0.7) {
                    entry["photoData"] = resized
                }
                return entry
            }
        ]

        if settings.groundingMediaType == .photo,
           let ref = settings.groundingMediaRef,
           let url = URL(string: ref),
           let originalData = try? Data(contentsOf: url),
           let resized = Self.resizedJPEGData(from: originalData, maxDimension: 400, quality: 0.6) {
            context["groundingImageData"] = resized
        } else {
            context["groundingImageData"] = NSNull()
        }

        try? WCSession.default.updateApplicationContext(context)
    }

    private static func resizedJPEGData(from data: Data, maxDimension: CGFloat, quality: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1.0, maxDimension / max(image.size.width, image.size.height))
        let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resized.jpegData(compressionQuality: quality)
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
}

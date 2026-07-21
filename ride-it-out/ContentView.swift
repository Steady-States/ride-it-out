import SwiftUI

@main
struct RideItOutApp: App {
    init() {
        excludeFromBackup()
        restoreHapticsDefault()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func excludeFromBackup() {
        if var url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            var values = URLResourceValues()
            values.isExcludedFromBackup = true
            try? url.setResourceValues(values)
        }
    }

    private func restoreHapticsDefault() {
        let key = StorageKey.hapticsEnabled.rawValue
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(true, forKey: key)
        }
    }
}

struct ContentView: View {
    @AppStorage("rideItOut_onboardingComplete") var onboardingComplete: Bool = false

    var body: some View {
        if onboardingComplete {
            MainView()
        } else {
            WelcomeView()
        }
    }
}

import SwiftUI

@main
struct RideItOutApp: App {
    init() {
        // Set default haptics enabled if unset
        let key = StorageKey.hapticsEnabled.rawValue
        if UserDefaults.standard.object(forKey: key) == nil {
            UserDefaults.standard.set(true, forKey: key)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    // excludeFromBackup() removed

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
#Preview {
    ContentView()
}

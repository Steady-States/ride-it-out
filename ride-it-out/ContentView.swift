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
}

struct ContentView: View {
    @AppStorage("rideItOut_onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage(StorageKey.appearance.rawValue) private var appearanceRaw: String = Appearance.system.rawValue

    private var colorScheme: ColorScheme? {
        (Appearance(rawValue: appearanceRaw) ?? .system).colorScheme
    }

    var body: some View {
        Group {
            if onboardingComplete {
                MainView()
            } else {
                WelcomeView()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}
#Preview {
    ContentView()
}

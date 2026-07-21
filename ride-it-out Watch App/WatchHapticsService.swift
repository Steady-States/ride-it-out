import WatchKit

enum WatchHapticsService {
    static func play(for phase: BreathingPhase, hapticsEnabled: Bool) {
        guard hapticsEnabled else { return }
        switch phase.type {
        case .inhale:
            WKInterfaceDevice.current().play(.start)
        case .exhale:
            WKInterfaceDevice.current().play(.stop)
        case .holdAfterInhale, .holdAfterExhale:
            WKInterfaceDevice.current().play(.click)
        }
    }
}

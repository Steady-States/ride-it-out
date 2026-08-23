#if os(iOS)
import CoreHaptics
import UIKit

class HapticsService {

    private var engine: CHHapticEngine?
    private var continuousPlayer: CHHapticAdvancedPatternPlayer?

    init() {
        prepareEngine()
    }

    private let supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
    private func prepareEngine() {
        guard supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true
            engine?.stoppedHandler = { [weak self] _ in
                self?.prepareEngine()
            }
            engine?.resetHandler = { [weak self] in
                try? self?.engine?.start()
            }
            try engine?.start()
        } catch {
            print("Haptics engine failed: \(error)")
        }
    }

    func playPhase(_ phase: BreathingPhase, modality: BreathingModality) {
        guard supportsHaptics else { return }
        guard UserDefaults.standard.bool(forKey: StorageKey.hapticsEnabled.rawValue) else { return }

        stopAll()

        switch phase.type {
        case .inhale:
            playRamp(duration: Double(phase.beats),
                     startIntensity: 0.4, endIntensity: 1.0,
                     startSharpness: 0.3, endSharpness: 0.8)
        case .exhale:
            playRamp(duration: Double(phase.beats),
                     startIntensity: 1.0, endIntensity: 0.1,
                     startSharpness: 0.8, endSharpness: 0.1)
        case .holdAfterInhale, .holdAfterExhale:
            break
        }
    }

    private func playRamp(
        duration: Double,
        startIntensity: Float, endIntensity: Float,
        startSharpness: Float, endSharpness: Float
    ) {
        guard let engine = engine else { return }
        do {
            let intensityCurve = CHHapticParameterCurve(
                parameterID: .hapticIntensityControl,
                controlPoints: [
                    .init(relativeTime: 0, value: startIntensity),
                    .init(relativeTime: duration, value: endIntensity)
                ],
                relativeTime: 0
            )
            let sharpnessCurve = CHHapticParameterCurve(
                parameterID: .hapticSharpnessControl,
                controlPoints: [
                    .init(relativeTime: 0, value: startSharpness),
                    .init(relativeTime: duration, value: endSharpness)
                ],
                relativeTime: 0
            )
            let continuousEvent = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    CHHapticEventParameter(parameterID: .hapticIntensity, value: startIntensity),
                    CHHapticEventParameter(parameterID: .hapticSharpness, value: startSharpness)
                ],
                relativeTime: 0,
                duration: duration
            )
            let pattern = try CHHapticPattern(
                events: [continuousEvent],
                parameterCurves: [intensityCurve, sharpnessCurve]
            )
            continuousPlayer = try engine.makeAdvancedPlayer(with: pattern)
            try continuousPlayer?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Haptics playback failed: \(error)")
        }
    }

    func stopAll() {
        try? continuousPlayer?.stop(atTime: CHHapticTimeImmediate)
        continuousPlayer = nil
    }

    func confirmStop() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
#endif

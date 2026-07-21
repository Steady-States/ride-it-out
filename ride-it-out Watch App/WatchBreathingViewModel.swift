import SwiftUI
import Combine

class WatchBreathingViewModel: ObservableObject {

    @Published var currentPhaseIndex: Int = 0
    @Published var currentBeat: Int = 1
    @Published var isRunning: Bool = false
    @Published var glowIntensity: Double = 0.15
    @Published var glowColor: Color = .glowExhale

    var hapticsEnabled: Bool = true
    var currentModality: BreathingModality = BreathingModalities.box
    var currentPhase: BreathingPhase { currentModality.phases[currentPhaseIndex] }

    private var beatTimer: Timer?

    func start(modality: BreathingModality? = nil) {
        if let modality = modality { currentModality = modality }
        isRunning = true
        currentPhaseIndex = 0
        currentBeat = currentPhase.beats
        startPhase()
    }

    func stop() {
        isRunning = false
        beatTimer?.invalidate()
        beatTimer = nil
    }

    private func startPhase() {
        let phase = currentPhase
        currentBeat = phase.beats
        triggerGlowAnimation(for: phase)
        WatchHapticsService.play(for: phase, hapticsEnabled: hapticsEnabled)
        beatTimer?.invalidate()
        beatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        if currentBeat > 1 {
            currentBeat -= 1
        } else {
            beatTimer?.invalidate()
            advancePhase()
        }
    }

    private func advancePhase() {
        currentPhaseIndex = (currentPhaseIndex + 1) % currentModality.phases.count
        startPhase()
    }

    private func triggerGlowAnimation(for phase: BreathingPhase) {
        let duration = Double(phase.beats)
        switch phase.type {
        case .inhale:
            glowColor = .glowInhale
            withAnimation(.linear(duration: duration)) {
                glowIntensity = 0.82
            }
        case .holdAfterInhale:
            withAnimation(.linear(duration: 0.6)) {
                glowColor = .glowHoldIn
                glowIntensity = 0.42
            }
        case .exhale:
            glowColor = .glowExhale
            withAnimation(.linear(duration: duration)) {
                glowIntensity = 0.68
            }
        case .holdAfterExhale:
            withAnimation(.linear(duration: 0.6)) {
                glowColor = .glowHoldOut
                glowIntensity = 0.22
            }
        }
    }
}

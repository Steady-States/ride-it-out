import SwiftUI
import Combine

class BreathingViewModel: ObservableObject {

    @Published var currentPhaseIndex: Int = 0
    @Published var currentBeat: Int = 1
    @Published var isRunning: Bool = false
    @Published var glowIntensity: Double = 0.15
    @Published var glowColor: Color = .breathingGlow

    var currentModality: BreathingModality = BreathingModalities.box
    var currentPhase: BreathingPhase { currentModality.phases[currentPhaseIndex] }

    private var beatTimer: Timer?
    #if os(iOS)
    private let hapticsService: HapticsService = HapticsService()
    #endif

    // MARK: - Control

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
        #if os(iOS)
        hapticsService.stopAll()
        hapticsService.confirmStop()
        #endif
    }

    func restart() {
        stop()
        currentPhaseIndex = 0
        glowIntensity = 0.15
        currentBeat = currentModality.phases[0].beats
        start()
    }

    // MARK: - Phase Engine

    private func startPhase() {
        let phase = currentPhase
        currentBeat = phase.beats
        triggerGlowAnimation(for: phase)
        #if os(iOS)
        hapticsService.playPhase(phase, modality: currentModality)
        #endif
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

    // MARK: - Glow

    private func triggerGlowAnimation(for phase: BreathingPhase) {
        let duration = Double(phase.beats)
        switch phase.type {
        case .inhale:
            withAnimation(.linear(duration: duration)) {
                glowIntensity = 1.0
            }
        case .holdAfterInhale:
            break
        case .exhale:
            withAnimation(.linear(duration: duration)) {
                glowIntensity = 0.15
            }
        case .holdAfterExhale:
            break
        }
    }
}

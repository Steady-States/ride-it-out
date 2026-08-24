import SwiftUI
import Combine

class BreathingViewModel: ObservableObject {

    @Published var currentPhaseIndex: Int = 0
    @Published var currentBeat: Int = 1
    @Published var isRunning: Bool = false
    @Published var bandColor: Color = PhaseType.holdAfterExhale.bandColor
    @Published var troughTarget: CGFloat = 0.1
    var troughDuration: Double = 0.4

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
        currentBeat = currentModality.phases[0].beats
        start()
    }

    // MARK: - Phase Engine

    private func startPhase() {
        let phase = currentPhase
        currentBeat = phase.beats
        updatePhaseTargets(for: phase)
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

    // MARK: - Band + trough targets

    private func updatePhaseTargets(for phase: BreathingPhase) {
        bandColor = phase.type.bandColor
        switch phase.type {
        case .inhale:
            troughDuration = Double(phase.beats)
            troughTarget = 1.0
        case .holdAfterInhale:
            troughDuration = 0.4
            troughTarget = 1.0
        case .exhale:
            troughDuration = Double(phase.beats)
            troughTarget = 0.1
        case .holdAfterExhale:
            troughDuration = 0.4
            troughTarget = 0.1
        }
    }
}

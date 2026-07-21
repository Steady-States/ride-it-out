import Foundation

enum PhaseType {
    case inhale
    case holdAfterInhale
    case exhale
    case holdAfterExhale
}

struct BreathingPhase {
    let label: String
    let beats: Int
    let type: PhaseType
}

struct BreathingModality: Identifiable {
    let id: String
    let label: String
    let description: String
    let phases: [BreathingPhase]
}

enum BreathingModalities {

    static let box = BreathingModality(
        id: "box",
        label: "Box Breathing",
        description: "A balanced pattern used to calm the nervous system and restore focus.",
        phases: [
            BreathingPhase(label: "INHALE", beats: 4, type: .inhale),
            BreathingPhase(label: "HOLD",   beats: 4, type: .holdAfterInhale),
            BreathingPhase(label: "EXHALE", beats: 4, type: .exhale),
            BreathingPhase(label: "HOLD",   beats: 4, type: .holdAfterExhale),
        ]
    )

    static let fourSevenEight = BreathingModality(
        id: "478",
        label: "4-7-8 Breathing",
        description: "A powerful pattern for rapid anxiety relief. The extended exhale activates your body's natural calming response.",
        phases: [
            BreathingPhase(label: "INHALE", beats: 4, type: .inhale),
            BreathingPhase(label: "HOLD",   beats: 7, type: .holdAfterInhale),
            BreathingPhase(label: "EXHALE", beats: 8, type: .exhale),
        ]
    )

    static let resonant = BreathingModality(
        id: "resonant",
        label: "Resonant Breathing",
        description: "A steady, even rhythm shown to reduce stress and improve heart rate variability.",
        phases: [
            BreathingPhase(label: "INHALE", beats: 5, type: .inhale),
            BreathingPhase(label: "EXHALE", beats: 5, type: .exhale),
        ]
    )

    static let extendedExhale = BreathingModality(
        id: "extended",
        label: "Extended Exhale",
        description: "Doubling the exhale length quickly engages the parasympathetic nervous system.",
        phases: [
            BreathingPhase(label: "INHALE", beats: 4, type: .inhale),
            BreathingPhase(label: "EXHALE", beats: 8, type: .exhale),
        ]
    )

    static let all: [BreathingModality] = [box, fourSevenEight, resonant, extendedExhale]
}

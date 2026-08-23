import SwiftUI
import Combine

class LifelinesViewModel: ObservableObject {

    @Published var lifelines: [Lifeline] = []

    init() {
        load()
    }

    func load() {
        lifelines = KeychainService.loadLifelines()

        if lifelines.isEmpty {
            lifelines = [
                Lifeline(name: "988 Crisis Lifeline", phone: "988"),
                Lifeline(name: "Samaritans UK", phone: "116123")
            ]
            persist()
        }
    }

    func addOrUpdate(_ lifeline: Lifeline) {
        if let index = lifelines.firstIndex(where: { $0.id == lifeline.id }) {
            lifelines[index] = lifeline
        } else {
            lifelines.append(lifeline)
        }
        persist()
    }

    func remove(_ lifeline: Lifeline) {
        lifelines.removeAll { $0.id == lifeline.id }
        persist()
    }

    func move(_ lifeline: Lifeline, to targetIndex: Int) {
        guard let fromIndex = lifelines.firstIndex(where: { $0.id == lifeline.id }),
              fromIndex != targetIndex else { return }
        lifelines.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: targetIndex > fromIndex ? targetIndex + 1 : targetIndex)
        persist()
    }

    private func persist() {
        KeychainService.saveLifelines(lifelines)
    }
}

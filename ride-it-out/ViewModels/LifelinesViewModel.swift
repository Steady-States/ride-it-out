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

    func move(fromOffsets offsets: IndexSet, toOffset destination: Int) {
        lifelines.move(fromOffsets: offsets, toOffset: destination)
        persist()
    }

    private func persist() {
        KeychainService.saveLifelines(lifelines)
    }
}

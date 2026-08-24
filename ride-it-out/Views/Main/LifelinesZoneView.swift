import SwiftUI

struct LifelinesZoneView: View {
    @ObservedObject var vm: LifelinesViewModel
    var onAddContact: () -> Void
    var onCustomize: () -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible())],
            spacing: 10
        ) {
            ForEach(0..<4, id: \.self) { index in
                cell(at: index)
            }
        }
        .padding(10)
    }

    @ViewBuilder
    private func cell(at index: Int) -> some View {
        if index < vm.lifelines.count {
            LifelineButton(lifeline: vm.lifelines[index])
        } else if index == 3 {
            EmptySlotButton(label: "Make it mine", action: onCustomize)
        } else {
            EmptySlotButton(label: "Add someone", action: onAddContact)
        }
    }
}

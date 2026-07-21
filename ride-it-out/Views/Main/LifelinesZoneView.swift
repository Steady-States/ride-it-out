import SwiftUI

struct LifelinesZoneView: View {
    @ObservedObject var vm: LifelinesViewModel
    var onAddContact: () -> Void
    var onCustomize: () -> Void

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            spacing: 8
        ) {
            ForEach(0..<4, id: \.self) { index in
                cell(at: index)
            }
        }
        .padding(8)
    }

    @ViewBuilder
    private func cell(at index: Int) -> some View {
        if index < vm.lifelines.count {
            LifelineButton(lifeline: vm.lifelines[index])
        } else if index == 3 {
            EmptySlotButton(label: "Customize My App", action: onCustomize)
        } else {
            EmptySlotButton(label: "Add a Contact", action: onAddContact)
        }
    }
}

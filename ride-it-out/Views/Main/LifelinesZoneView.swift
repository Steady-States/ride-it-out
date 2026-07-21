import SwiftUI

struct LifelinesZoneView: View {
    @ObservedObject var vm: LifelinesViewModel
    var onAddContact: () -> Void
    var onCustomize: () -> Void

    var body: some View {
        let filled = vm.filledLifelines
        if filled.isEmpty {
            EmptyView()
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 10
            ) {
                ForEach(filled) { lifeline in
                    LifelineButton(lifeline: lifeline, displayMode: vm.displayMode)
                }
                if vm.lifeline3 == nil {
                    EmptySlotButton(label: "Add a Contact", action: onAddContact)
                }
                if vm.lifeline4 == nil {
                    EmptySlotButton(label: "Customize My App", action: onCustomize)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

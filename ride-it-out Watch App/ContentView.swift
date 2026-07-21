import SwiftUI

struct ContentView: View {
    @StateObject private var syncReceiver = WatchSyncReceiver()
    @StateObject private var breathingVM = WatchBreathingViewModel()
    @State private var selectedPane = 0

    var body: some View {
        TabView(selection: $selectedPane) {
            BreathingPaneView(vm: breathingVM)
                .tag(0)

            GroundingImagePaneView(imageData: syncReceiver.groundingImageData)
                .tag(1)

            ForEach(0..<4, id: \.self) { index in
                lifelinePane(at: index)
                    .tag(2 + index)
            }
        }
        .tabViewStyle(.verticalPage)
        .onAppear {
            syncReceiver.activate()
            breathingVM.hapticsEnabled = syncReceiver.hapticsEnabled
            let initialModality = BreathingModalities.all.first { $0.id == syncReceiver.modalityID } ?? BreathingModalities.box
            breathingVM.start(modality: initialModality)
        }
        .onChange(of: syncReceiver.hapticsEnabled) { _, newValue in
            breathingVM.hapticsEnabled = newValue
        }
    }

    @ViewBuilder
    private func lifelinePane(at index: Int) -> some View {
        if index < syncReceiver.lifelines.count {
            LifelinePaneView(lifeline: syncReceiver.lifelines[index])
        } else {
            EmptyLifelinePaneView()
        }
    }
}

#Preview {
    ContentView()
}

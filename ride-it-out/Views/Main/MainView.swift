import SwiftUI

struct MainView: View {
    @StateObject private var breathingVM = BreathingViewModel()
    @StateObject private var lifelinesVM = LifelinesViewModel()
    @StateObject private var settingsVM = SettingsViewModel()

    @State private var showSettings = false
    @State private var guidedTourActive = false

    var startWithTour: Bool = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    Color.background.ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Zone 1 — Breathing (1/6)
                        BreathingZoneView(
                            vm: breathingVM,
                            selectedModality: settingsVM.selectedModality,
                            onPatternChange: { modality in
                                settingsVM.saveModalityID(modality.id)
                                breathingVM.start(modality: modality)
                            }
                        )
                        .frame(height: geometry.size.height / 6)

                        // Zone 2 — Grounding Media (3/6)
                        GroundingMediaView(
                            mediaType: settingsVM.groundingMediaType,
                            mediaRef: settingsVM.groundingMediaRef,
                            videoSound: settingsVM.groundingVideoSound,
                            transformScale: settingsVM.groundingMediaScale,
                            transformOffsetFraction: CGSize(
                                width: settingsVM.groundingMediaOffsetXFraction,
                                height: settingsVM.groundingMediaOffsetYFraction
                            ),
                            onAddMedia: { showSettings = true },
                            showTourButton: !guidedTourActive,
                            onStartTour: { guidedTourActive = true }
                        )
                        .frame(height: geometry.size.height * 3 / 6)

                        // Zone 3 — Lifelines (2/6)
                        LifelinesZoneView(
                            vm: lifelinesVM,
                            onAddContact: { showSettings = true },
                            onCustomize: { showSettings = true }
                        )
                        .frame(height: geometry.size.height * 2 / 6)
                    }

                    GlowAnimationView(breathingVM: breathingVM)

                    if guidedTourActive {
                        TourOverlayView(isActive: $guidedTourActive)
                    }

                    Button(action: { showSettings = true }) {
                        Image(systemName: "gear")
                            .font(.system(size: 17))
                            .foregroundColor(.textTertiary)
                            .frame(width: 44, height: 44)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 4)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(settingsVM: settingsVM, lifelinesVM: lifelinesVM, onStartTour: {
                    showSettings = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        guidedTourActive = true
                    }
                })
            }
        }
        .onAppear {
            breathingVM.start(modality: settingsVM.selectedModality)
            if startWithTour {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    guidedTourActive = true
                }
            }
            WatchSyncService.shared.activate()
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .onOpenURL { url in
            if url.scheme == "rideitout" {
                if !breathingVM.isRunning {
                    breathingVM.restart()
                }
            }
        }
        .onChange(of: settingsVM.selectedModalityID) {
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .onChange(of: settingsVM.hapticsEnabled) {
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .onChange(of: settingsVM.groundingMediaType) {
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .onChange(of: settingsVM.groundingMediaRef) {
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .onChange(of: lifelinesVM.lifelines) {
            WatchSyncService.shared.sync(settings: settingsVM, lifelines: lifelinesVM)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainView()
}

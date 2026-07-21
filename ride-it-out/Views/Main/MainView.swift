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
                            onSettingsTap: { showSettings = true },
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
                }
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(settingsVM: settingsVM, lifelinesVM: lifelinesVM)
            }
        }
        .onAppear {
            breathingVM.start(modality: settingsVM.selectedModality)
            if startWithTour {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    guidedTourActive = true
                }
            }
        }
        .onOpenURL { url in
            if url.scheme == "rideitout" {
                if !breathingVM.isRunning {
                    breathingVM.restart()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    MainView()
}

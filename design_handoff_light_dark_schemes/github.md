repo: Steady-States/ride-it-out
branch: main

## Last sync
date: 2026-08-24T02:20:00Z

### Updated in this project
- Recreated the current dark iOS build from source as a baseline reference.
- Proposed a warm paper light scheme and a warm-ink dark mirror across nine screens.
- Replaced the blurred edge glow with a flat tinted edge band, one colour per breath phase.
- Added a wave-trough breath counter that fills on the inhale and drains on the exhale.

## Screen map
| Project screen | Repo files |
| --- | --- |
| Welcome | ride-it-out/Views/Onboarding/WelcomeView.swift, ride-it-out/Constants/Colors.swift |
| Home | ride-it-out/Views/Main/MainView.swift, BreathingZoneView.swift, GroundingMediaView.swift, LifelinesZoneView.swift, ride-it-out/Components/LifelineButton.swift, ride-it-out/Components/GlowAnimationView.swift, ride-it-out/ViewModels/BreathingViewModel.swift |
| Guided tour | ride-it-out/Components/TourOverlayView.swift |
| Settings | ride-it-out/Views/Settings/SettingsView.swift |
| Breathing patterns | ride-it-out/Views/Settings/CustomizeBreathingView.swift, ride-it-out/Constants/BreathingModalities.swift |
| Grounding anchor | ride-it-out/Views/Settings/GroundingMediaSettingsView.swift |
| Lifelines | ride-it-out/Views/Settings/CustomizeLifelinesView.swift, ride-it-out/Models/Lifeline.swift |
| Reminders | ride-it-out/Views/Settings/RemindersView.swift |
| Privacy (baseline only) | ride-it-out/Views/Settings/PrivacyView.swift |
| Watch | ride-it-out Watch App/ContentView.swift, BreathingPaneView.swift, GroundingImagePaneView.swift, LifelinePaneView.swift, Colors.swift |

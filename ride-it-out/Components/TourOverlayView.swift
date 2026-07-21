import SwiftUI

struct TourStop {
    enum Zone { case breathing, glow, groundingMedia, lifelines, settings }
    let highlightZone: Zone
    let text: String
}

struct TourOverlayView: View {
    @Binding var isActive: Bool
    @State private var currentStop: Int = 0
    @State private var visible: Bool = false
    var onNavigateToSettings: (() -> Void)?

    let stops: [TourStop] = [
        TourStop(highlightZone: .breathing,
                 text: "With Box Breathing, you're helping your body regulate intense feelings. Follow the counter to breathe in for four beats, hold for four beats, exhale for four beats, and hold for four beats. Haptic vibrations will guide your inhale and exhale. This starts automatically every time you open the app."),
        TourStop(highlightZone: .glow,
                 text: "The edges of your screen glow with your breath. They brighten as you inhale and dim as you exhale. Let the light guide you."),
        TourStop(highlightZone: .groundingMedia,
                 text: "Choose an image, video, or words that remind you of stability and clarity. This could be a loved one, a place that calms you, or a saying that resonates. You can set this up in Settings anytime."),
        TourStop(highlightZone: .lifelines,
                 text: "These buttons directly call people you trust. One tap — no confirmation screen. Two hotlines are set up for you by default. Add your own contacts in Settings — a sponsor, a friend, a family member. Anyone who helps you stay grounded."),
        TourStop(highlightZone: .settings,
                 text: "Everything in Ride It Out is customizable. Tap here anytime to change your breathing style, update your grounding media, or edit your lifeline contacts. We recommend setting things up before a crisis — so when it comes, the app is ready for you."),
    ]

    var body: some View {
        if isActive && visible {
            ZStack {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)

                VStack {
                    Spacer()
                    tourCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: currentStop)
        }
    }

    private var tourCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(stops[currentStop].text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                if currentStop < stops.count - 1 {
                    Button("Skip Tour") {
                        endTour()
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)

                    Spacer()

                    Button("Next") {
                        withAnimation { currentStop += 1 }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentCyan)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.accentCyan.opacity(0.15))
                    .clipShape(Capsule())
                } else {
                    Spacer()
                    Button("Done") {
                        endTour()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.accentCyan)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.accentCyan.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(24)
        .background(Color.surfaceCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.accentCyan.opacity(0.2), lineWidth: 1)
        )
    }

    private func endTour() {
        withAnimation { isActive = false }
    }

    func startDelayed() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation { visible = true }
        }
    }
}

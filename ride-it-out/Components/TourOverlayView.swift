import SwiftUI

enum TourCardAnchor {
    case top
    case bottom
}

struct TourStop {
    let title: String
    let text: String
    // Highlighted zone, expressed as fractions of total height
    let zoneTop: Double
    let zoneHeight: Double
    // Which edge the card is pinned to, and how far from it (fraction of
    // total height). Stops 2 and 3 share the same bottom anchor — just
    // above the lifelines zone — so the card never slides down over the
    // lifelines it's introducing on stop 3.
    let cardAnchor: TourCardAnchor
    let cardOffsetFraction: Double
}

struct TourOverlayView: View {
    @Binding var isActive: Bool
    var totalHeight: CGFloat
    @State private var currentStop: Int = 0
    var onNavigateToSettings: (() -> Void)? = nil

    private let stops: [TourStop] = [
        TourStop(
            title: "Breathe with it",
            text: "The number counts down each beat. Your only job is to follow it. Breathe in as it counts, hold when it says HOLD, let go on EXHALE.",
            zoneTop: 0,
            zoneHeight: 1.0 / 6.0,
            cardAnchor: .top,
            cardOffsetFraction: 1.0 / 6.0
        ),
        TourStop(
            title: "Your grounding anchor",
            text: "This is your safe space — a photo, a video, or a phrase that pulls you back to solid ground. Set it up in settings.",
            zoneTop: 1.0 / 6.0,
            zoneHeight: 3.0 / 6.0,
            cardAnchor: .bottom,
            cardOffsetFraction: 2.0 / 6.0
        ),
        TourStop(
            title: "Your lifelines",
            text: "Four people who will pick up. Put them here once and you can reach them in two taps, without thinking, on the worst night.",
            zoneTop: 4.0 / 6.0,
            zoneHeight: 2.0 / 6.0,
            cardAnchor: .bottom,
            cardOffsetFraction: 2.0 / 6.0
        ),
    ]

    var body: some View {
        let stop = stops[currentStop]
        let topH  = totalHeight * stop.zoneTop
        let zoneH = totalHeight * stop.zoneHeight
        let cardOffset = totalHeight * stop.cardOffsetFraction + 12

        ZStack(alignment: stop.cardAnchor == .top ? .top : .bottom) {
            // Spotlight: dim bars above and below highlighted zone
            VStack(spacing: 0) {
                Color.scrimHeavy.frame(height: topH)
                Color.clear.frame(height: zoneH)
                Color.scrimHeavy
            }

            // Accent ring around highlighted zone
            VStack(spacing: 0) {
                Color.clear.frame(height: topH)
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.accent.opacity(0.5), lineWidth: 2)
                    .padding(.horizontal, 8)
                    .frame(height: zoneH)
                Color.clear
            }

            // Floating info card — anchored beside the highlighted zone,
            // never on top of it
            card(for: stop)
                .padding(.horizontal, 16)
                .padding(stop.cardAnchor == .top ? .top : .bottom, cardOffset)
        }
        .frame(height: totalHeight)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStop)
    }

    @ViewBuilder
    private func card(for stop: TourStop) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step indicator dots
            HStack(spacing: 5) {
                ForEach(0..<stops.count, id: \.self) { i in
                    Capsule()
                        .fill(Color.accent)
                        .opacity(i <= currentStop ? 1 : 0.3)
                        .frame(width: i == currentStop ? 24 : 9, height: 4)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: currentStop)
            .padding(.bottom, 14)

            Text(stop.title)
                .font(.displaySerif(size: 21))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 8)

            Text(stop.text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.textSecondary)
                .lineSpacing(7)
                .padding(.bottom, 16)

            HStack(spacing: 10) {
                Button {
                    if currentStop < stops.count - 1 {
                        currentStop += 1
                    } else {
                        withAnimation { isActive = false }
                    }
                } label: {
                    Text(currentStop < stops.count - 1 ? "Next" : "Got it")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.accentOn)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(Color.accent)
                        .clipShape(Capsule())
                }

                Button {
                    withAnimation { isActive = false }
                } label: {
                    Text("Skip")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, 22)
        .padding(.top, 20)
        .padding(.bottom, 18)
        .background(Color.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: Color(hex: 0x2E2B25, alpha: 0.32), radius: 32, x: 0, y: 12)
    }
}

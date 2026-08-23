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
            text: "These are the people who will pick up. Add them in settings and you can call them directly from here, any time, in seconds.",
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
                Color.black.opacity(0.68).frame(height: topH)
                Color.clear.frame(height: zoneH)
                Color.black.opacity(0.68)
            }

            // Accent ring around highlighted zone
            VStack(spacing: 0) {
                Color.clear.frame(height: topH)
                Rectangle()
                    .stroke(Color.accentCyan.opacity(0.25), lineWidth: 1)
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
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i <= currentStop ? Color.accentCyan : Color.borderColor)
                        .frame(width: i == currentStop ? 20 : 8, height: 3)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: currentStop)
            .padding(.bottom, 12)

            Text(stop.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.textPrimary)
                .padding(.bottom, 6)

            Text(stop.text)
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
                .lineSpacing(4)
                .padding(.bottom, 14)

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
                        .foregroundColor(.background)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color.accentCyan)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                Button {
                    withAnimation { isActive = false }
                } label: {
                    Text("Skip")
                        .font(.system(size: 13))
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .background(Color.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.borderColor, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.65), radius: 20, x: 0, y: 8)
    }
}

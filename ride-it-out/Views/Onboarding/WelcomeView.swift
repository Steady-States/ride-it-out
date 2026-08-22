import SwiftUI

struct WelcomeView: View {
    @AppStorage("rideItOut_onboardingComplete") private var onboardingComplete: Bool = false
    @State private var navigateToMain = false
    @State private var startWithTour = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            // Ambient edge glow — subtle hint of what's on the main screen
            Rectangle()
                .stroke(Color.accentCyan, lineWidth: 20)
                .blur(radius: 40)
                .opacity(0.05)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer()

                // Title + tagline
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ride It Out")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.textPrimary)
                        .tracking(-1.2)

                    Text("Your partner in\nserenity.")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.textSecondary)
                        .lineSpacing(4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)

                // Buttons
                VStack(spacing: 10) {
                    Button {
                        onboardingComplete = true
                        startWithTour = false
                        navigateToMain = true
                    } label: {
                        Text("Get Help Now")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.accentCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button {
                        onboardingComplete = true
                        startWithTour = true
                        navigateToMain = true
                    } label: {
                        Text("Set Up My Ride")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.accentCyan)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.clear)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.accentCyan, lineWidth: 1.5)
                            )
                    }
                }
                .padding(.horizontal, 24)

                // Divider + footer text
                Color.borderColor
                    .frame(height: 1)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)

                VStack(spacing: 6) {
                    Text("Breathe. Ground yourself. Call someone.")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)

                    Text("* No account required. All data stays on your device.")
                        .font(.system(size: 12))
                        .foregroundColor(.textTertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 44)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $navigateToMain) {
            MainView(startWithTour: startWithTour)
                .interactiveDismissDisabled(true)
        }
    }
}
#Preview {
    WelcomeView()
}

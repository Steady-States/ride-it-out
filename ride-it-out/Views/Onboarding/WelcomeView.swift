import SwiftUI

struct WelcomeView: View {
    @AppStorage("rideItOut_onboardingComplete") private var onboardingComplete: Bool = false
    @State private var navigateToMain = false
    @State private var startWithTour = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topTrailing) {
                Color.background.ignoresSafeArea()

                Circle()
                    .fill(Color.tint)
                    .frame(width: 340, height: 340)
                    .offset(x: 100, y: -120)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.accentFill)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "water.waves")
                                .font(.system(size: 34, weight: .semibold))
                                .foregroundColor(.accentText)
                        )
                        .shadow(color: Color(hex: 0x2E2B25, alpha: 0.16), radius: 10, x: 0, y: 3)

                    Text("Ride It Out")
                        .font(.displaySerif(size: 46))
                        .foregroundColor(.textPrimary)
                        .padding(.top, 28)

                    Text("You don't have to fight the wave. You just have to stay on it.")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.textSecondary)
                        .lineSpacing(8)
                        .frame(maxWidth: 220, alignment: .leading)
                        .padding(.top, 14)

                    VStack(spacing: 12) {
                        Button {
                            onboardingComplete = true
                            startWithTour = false
                            navigateToMain = true
                        } label: {
                            Text("I need help right now")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.accentOn)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.accent)
                                .clipShape(Capsule())
                        }

                        Button {
                            onboardingComplete = true
                            startWithTour = true
                            navigateToMain = true
                        } label: {
                            Text("Set up my ride")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.accentText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(Color.clear)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(Color.accent, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.top, 40)

                    VStack(spacing: 7) {
                        Text("Breathe. Ground yourself. Call someone.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)

                        Text("No account. Nothing ever leaves this phone.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 26)
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 46)
            }
        }
        .sheet(isPresented: $navigateToMain) {
            MainView(startWithTour: startWithTour)
                .interactiveDismissDisabled(true)
        }
    }
}
#Preview {
    WelcomeView()
}

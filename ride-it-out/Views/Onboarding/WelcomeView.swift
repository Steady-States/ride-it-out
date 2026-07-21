import SwiftUI

struct WelcomeView: View {
    @AppStorage("rideItOut_onboardingComplete") private var onboardingComplete: Bool = false
    @State private var navigateToMain = false
    @State private var startWithTour = false

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 8) {
                    Text("Ride It Out")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(.textPrimary)

                    Text("Your partner in serenity.")
                        .font(.system(size: 17, weight: .light))
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        onboardingComplete = true
                        startWithTour = false
                        navigateToMain = true
                    } label: {
                        Text("Get Help Now")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.background)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.accentCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        onboardingComplete = true
                        startWithTour = true
                        navigateToMain = true
                    } label: {
                        Text("Set Up My Fighter")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.accentCyan)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.accentCyan.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentCyan.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 28)

                Text(descriptionText)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $navigateToMain) {
            MainView(startWithTour: startWithTour)
                .interactiveDismissDisabled(true)
        }
    }

    private let descriptionText = """
Ride It Out is an action app that helps divert compulsive behavior through immediate access to proven methods of grounding techniques and lifelines. All tools are customizable and it's recommended you spend time before a crisis setting up what works for you. When a crisis comes, opening the app will take you directly to the main screen so you can receive help immediately. The app can also be triggered by various widgets or preset reminder times.

* Please note, the app will ask for permission to access your contacts to set up lifeline calls. All data is stored on your device and erasable at any time.
"""
}

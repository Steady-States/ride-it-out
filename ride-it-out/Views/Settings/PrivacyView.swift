import SwiftUI

struct PrivacyView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 52))
                    .foregroundColor(.accentText)

                VStack(spacing: 16) {
                    Text("Ride It Out stores all your data on this device only.")
                        .font(.system(size: 17))
                        .foregroundColor(.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("No account is required. Nothing you enter — your contacts, your media, your patterns — is ever sent anywhere. When you delete the app, it's gone completely.")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)

                    Text("We don't want your data. We want you to be okay.")
                        .font(.system(size: 15))
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .frame(maxWidth: 320)
            }
            .padding(.horizontal, 28)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background.ignoresSafeArea())
        .navigationTitle("Privacy & Data")
    }
}

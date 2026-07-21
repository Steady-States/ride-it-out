import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            Text(privacyText)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.textSecondary)
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Privacy & Data")
        .background(Color.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }

    private let privacyText = """
Ride It Out stores all your data on this device only. Nothing is uploaded, shared, or transmitted. We don't collect analytics, track usage, or know who you are. Your lifeline contacts are encrypted on your device. You can erase everything at any time using Reset Data in Settings.
"""
}

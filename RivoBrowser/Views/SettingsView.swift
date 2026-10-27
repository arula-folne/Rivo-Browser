import SwiftUI

/// Placeholder settings — content TBD.
struct SettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Settings")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .padding(.top, 16)

            Text("Placeholder")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Rivo settings will land here later — engine prefs, one-handed layout options, privacy, and search provider.")
                .font(.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    SettingsView()
}

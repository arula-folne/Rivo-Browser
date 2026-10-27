import SwiftUI

/// Root shell: content above a fixed three-item bottom chrome.
struct BrowserShellView: View {
    @EnvironmentObject private var store: BrowserStore

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch store.mode {
                case .tabs:
                    TabsSwitcherView()
                case .newTab:
                    NewTabView()
                case .settings:
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            BottomChromeView()
        }
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    BrowserShellView()
        .environmentObject(BrowserStore())
}

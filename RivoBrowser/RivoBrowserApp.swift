import SwiftUI

@main
struct RivoBrowserApp: App {
    @StateObject private var store = BrowserStore()

    var body: some Scene {
        WindowGroup {
            BrowserShellView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
        }
    }
}

import Foundation

/// Bottom chrome modes — the only primary navigation surfaces.
enum BrowserChromeMode: String, CaseIterable, Identifiable {
    case tabs
    case newTab
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tabs: return "Tabs"
        case .newTab: return "New Tab"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .tabs: return "square.on.square"
        case .newTab: return "plus"
        case .settings: return "gearshape"
        }
    }
}

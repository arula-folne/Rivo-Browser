import Foundation

/// Thin abstraction over page rendering.
///
/// App Store iOS path: the only implementation is `WKWebViewBrowserEngine`
/// (system WebKit). Kept as a protocol so UI/state stay decoupled from WK types.
@MainActor
protocol BrowserEngine: AnyObject {
    var currentURL: URL? { get }
    var pageTitle: String { get }
    var isLoading: Bool { get }
    var estimatedProgress: Double { get }

    func load(url: URL)
    func loadQuery(_ query: String)
    func goBack()
    func goForward()
    func reload()
    func stopLoading()
}

extension BrowserEngine {
    /// Turns free text into either a URL or a search URL.
    static func resolveNavigationTarget(from input: String) -> URL? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }

        if trimmed.contains("."), !trimmed.contains(" "),
           let url = URL(string: "https://\(trimmed)") {
            return url
        }

        var components = URLComponents(string: "https://www.google.com/search")
        components?.queryItems = [URLQueryItem(name: "q", value: trimmed)]
        return components?.url
    }
}

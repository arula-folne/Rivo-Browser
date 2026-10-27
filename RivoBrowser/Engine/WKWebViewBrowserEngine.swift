import Combine
import Foundation
import WebKit

/// System WebKit (`WKWebView`) engine — the App Store iOS rendering path.
@MainActor
final class WKWebViewBrowserEngine: NSObject, ObservableObject, BrowserEngine {
    let webView: WKWebView

    @Published private(set) var currentURL: URL?
    @Published private(set) var pageTitle: String = ""
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var estimatedProgress: Double = 0

    private var observations: [NSKeyValueObservation] = []

    override init() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        super.init()
        webView.navigationDelegate = self
        observeWebView()
    }

    func load(url: URL) {
        currentURL = url
        webView.load(URLRequest(url: url))
    }

    func loadQuery(_ query: String) {
        guard let url = Self.resolveNavigationTarget(from: query) else { return }
        load(url: url)
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }

    func reload() {
        webView.reload()
    }

    func stopLoading() {
        webView.stopLoading()
    }

    private func observeWebView() {
        observations = [
            webView.observe(\.url, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in
                    self?.currentURL = view.url
                }
            },
            webView.observe(\.title, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in
                    self?.pageTitle = view.title ?? ""
                }
            },
            webView.observe(\.isLoading, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in
                    self?.isLoading = view.isLoading
                }
            },
            webView.observe(\.estimatedProgress, options: [.new]) { [weak self] view, _ in
                Task { @MainActor in
                    self?.estimatedProgress = view.estimatedProgress
                }
            }
        ]
    }
}

extension WKWebViewBrowserEngine: WKNavigationDelegate {
    nonisolated func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        Task { @MainActor in
            currentURL = webView.url
            pageTitle = webView.title ?? currentURL?.host ?? ""
        }
    }
}

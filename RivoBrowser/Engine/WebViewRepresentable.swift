import SwiftUI
import WebKit

/// Bridges `WKWebView` into SwiftUI.
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Engine owns navigation; no-op on SwiftUI updates.
    }
}

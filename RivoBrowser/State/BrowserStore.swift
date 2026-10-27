import Combine
import Foundation
import SwiftUI

/// In-memory browser session: tabs, history stubs, chrome mode, focus.
@MainActor
final class BrowserStore: ObservableObject {
    @Published var mode: BrowserChromeMode = .newTab
    @Published var tabs: [BrowserTab] = []
    @Published var activeTabID: UUID?
    @Published var searchHistory: [SearchHistoryItem]
    @Published var searchText: String = ""
    /// Bumped to request the search field become first responder.
    @Published var searchFocusToken: Int = 0

    let engine = WKWebViewBrowserEngine()

    private var engineCancellables = Set<AnyCancellable>()

    init() {
        searchHistory = Self.stubHistory()
        let first = BrowserTab()
        tabs = [first]
        activeTabID = first.id
        bindEngine()
        // Launch: New Tab + keyboard ready.
        requestSearchFocus()
    }

    var activeTab: BrowserTab? {
        guard let activeTabID else { return nil }
        return tabs.first { $0.id == activeTabID }
    }

    var showingPage: Bool {
        mode == .newTab && !(activeTab?.urlString.isEmpty ?? true)
    }

    func selectMode(_ newMode: BrowserChromeMode) {
        mode = newMode
        if newMode == .newTab {
            // Arc-like new tab: empty entry surface with keyboard.
            if let id = activeTabID,
               let index = tabs.firstIndex(where: { $0.id == id }),
               !tabs[index].urlString.isEmpty {
                // Keep current page; user can still edit the bar.
            }
            requestSearchFocus()
        }
    }

    func openNewTab() {
        let tab = BrowserTab()
        tabs.insert(tab, at: 0)
        activeTabID = tab.id
        searchText = ""
        mode = .newTab
        requestSearchFocus()
    }

    func selectTab(_ id: UUID) {
        guard tabs.contains(where: { $0.id == id }) else { return }
        activeTabID = id
        if let tab = tabs.first(where: { $0.id == id }) {
            searchText = tab.urlString
            if tab.urlString.isEmpty {
                mode = .newTab
                requestSearchFocus()
            } else if let url = URL(string: tab.urlString) {
                mode = .newTab
                engine.load(url: url)
            }
        }
    }

    func closeTab(_ id: UUID) {
        guard let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        tabs.remove(at: index)
        if tabs.isEmpty {
            openNewTab()
            return
        }
        if activeTabID == id {
            let next = tabs[min(index, tabs.count - 1)]
            selectTab(next.id)
        }
    }

    func submitSearch() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        engine.loadQuery(query)
        let resolved = WKWebViewBrowserEngine.resolveNavigationTarget(from: query)?.absoluteString ?? query

        if let id = activeTabID,
           let index = tabs.firstIndex(where: { $0.id == id }) {
            tabs[index].urlString = resolved
            tabs[index].title = query
            tabs[index].isLoading = true
        }

        let item = SearchHistoryItem(query: query, urlString: resolved)
        searchHistory.removeAll { $0.query.caseInsensitiveCompare(query) == .orderedSame }
        searchHistory.insert(item, at: 0)
        mode = .newTab
    }

    func openHistoryItem(_ item: SearchHistoryItem) {
        searchText = item.query
        submitSearch()
    }

    func requestSearchFocus() {
        searchFocusToken += 1
    }

    private func bindEngine() {
        engine.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
                self?.syncActiveTabFromEngine()
            }
            .store(in: &engineCancellables)
    }

    private func syncActiveTabFromEngine() {
        guard let id = activeTabID,
              let index = tabs.firstIndex(where: { $0.id == id }) else { return }
        if let url = engine.currentURL?.absoluteString, !url.isEmpty {
            tabs[index].urlString = url
        }
        if !engine.pageTitle.isEmpty {
            tabs[index].title = engine.pageTitle
        }
        tabs[index].isLoading = engine.isLoading
    }

    private static func stubHistory() -> [SearchHistoryItem] {
        [
            SearchHistoryItem(
                query: "Arc Search alternatives",
                urlString: "https://www.google.com/search?q=Arc+Search+alternatives",
                visitedAt: Date().addingTimeInterval(-3600)
            ),
            SearchHistoryItem(
                query: "one handed iOS browser",
                urlString: "https://www.google.com/search?q=one+handed+iOS+browser",
                visitedAt: Date().addingTimeInterval(-7200)
            ),
            SearchHistoryItem(
                query: "apple.com",
                urlString: "https://www.apple.com",
                visitedAt: Date().addingTimeInterval(-10_800)
            ),
            SearchHistoryItem(
                query: "WKWebView browser tips",
                urlString: "https://www.google.com/search?q=WKWebView+browser+tips",
                visitedAt: Date().addingTimeInterval(-14_400)
            )
        ]
    }
}

import SwiftUI

/// Arc-like new tab: history list + bottom search bar + keyboard.
struct NewTabView: View {
    @EnvironmentObject private var store: BrowserStore

    var body: some View {
        VStack(spacing: 0) {
            if store.showingPage {
                pageSurface
            } else {
                historySurface
            }

            searchFooter
        }
    }

    private var historySurface: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Rivo")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 8)

            Text("Recent")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

            List {
                ForEach(store.searchHistory) { item in
                    Button {
                        store.openHistoryItem(item)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.query)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                Text(item.urlString)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer(minLength: 0)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    private var pageSurface: some View {
        VStack(spacing: 0) {
            if store.engine.isLoading {
                ProgressView(value: store.engine.estimatedProgress)
                    .tint(.accentColor)
                    .padding(.horizontal, 12)
            }
            WebViewRepresentable(webView: store.engine.webView)
                .ignoresSafeArea(edges: .horizontal)
        }
    }

    private var searchFooter: some View {
        VStack(spacing: 8) {
            if store.showingPage, let title = store.activeTab?.title, !title.isEmpty {
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
            }
            SearchBarView()
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
        }
        .padding(.top, 8)
        .background(Color.black.opacity(0.55))
    }
}

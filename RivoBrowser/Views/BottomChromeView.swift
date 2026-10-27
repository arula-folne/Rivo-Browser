import SwiftUI

/// Primary one-handed controls — Tabs | New Tab | Settings only.
struct BottomChromeView: View {
    @EnvironmentObject private var store: BrowserStore

    var body: some View {
        HStack(spacing: 0) {
            chromeButton(.tabs)
            newTabButton
            chromeButton(.settings)
        }
        .padding(.horizontal, 12)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(alignment: .top) {
                    Divider().opacity(0.35)
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func chromeButton(_ mode: BrowserChromeMode) -> some View {
        Button {
            store.selectMode(mode)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: mode.systemImage)
                    .font(.system(size: 20, weight: .semibold))
                Text(mode.title)
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(store.mode == mode ? Color.accentColor : Color.secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(mode.title)
    }

    private var newTabButton: some View {
        Button {
            store.openNewTab()
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor.opacity(0.18))
                        .frame(width: 44, height: 44)
                    Image(systemName: BrowserChromeMode.newTab.systemImage)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.accentColor)
                }
                Text(BrowserChromeMode.newTab.title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(
                        store.mode == .newTab ? Color.accentColor : Color.secondary
                    )
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New Tab")
    }
}

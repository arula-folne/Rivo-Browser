import SwiftUI

/// iOS app-switcher–like card stack with swipe-to-close.
struct TabsSwitcherView: View {
    @EnvironmentObject private var store: BrowserStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tabs")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                Spacer()
                Text("\(store.tabs.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color(.secondarySystemBackground)))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(store.tabs) { tab in
                        TabCardView(tab: tab)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 8)
                .padding(.bottom, 24)
            }
        }
    }
}

private struct TabCardView: View {
    @EnvironmentObject private var store: BrowserStore
    let tab: BrowserTab

    @State private var dragOffset: CGSize = .zero

    var body: some View {
        Button {
            store.selectTab(tab.id)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(tab.title.isEmpty ? "New Tab" : tab.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    Spacer()
                    Text(tab.displayHost)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .padding(12)

                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.12, green: 0.14, blue: 0.20),
                                    Color(red: 0.08, green: 0.09, blue: 0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    VStack(spacing: 8) {
                        Image(systemName: "globe")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(.secondary)
                        Text(tab.urlString.isEmpty ? "Blank tab" : tab.urlString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                    }
                }
                .frame(height: 160)
                .padding([.horizontal, .bottom], 10)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.35), radius: 12, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        store.activeTabID == tab.id
                            ? Color.accentColor.opacity(0.8)
                            : Color.white.opacity(0.06),
                        lineWidth: store.activeTabID == tab.id ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
        .offset(x: dragOffset.width)
        .opacity(Double(1 - min(abs(dragOffset.width) / 220, 0.85)))
        .rotationEffect(.degrees(Double(dragOffset.width / 40)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    // Prefer horizontal swipe to dismiss (app-switcher feel).
                    if abs(value.translation.width) > abs(value.translation.height) {
                        dragOffset = CGSize(width: value.translation.width, height: 0)
                    }
                }
                .onEnded { value in
                    if abs(value.translation.width) > 120 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            dragOffset = CGSize(
                                width: value.translation.width > 0 ? 500 : -500,
                                height: 0
                            )
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            store.closeTab(tab.id)
                            dragOffset = .zero
                        }
                    } else {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            dragOffset = .zero
                        }
                    }
                }
        )
        .accessibilityHint("Swipe sideways to close")
    }
}

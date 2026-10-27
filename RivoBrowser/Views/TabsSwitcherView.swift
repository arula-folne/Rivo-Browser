import SwiftUI

/// Arc Search / iOS App Switcher–style horizontal overlapping tab carousel.
/// - Horizontal drag: move between tabs
/// - Swipe up on the front card: close that tab
/// - Tap front card: open / select it
struct TabsSwitcherView: View {
    @EnvironmentObject private var store: BrowserStore

    @State private var focusedIndex: Int = 0
    @State private var dragTranslation: CGSize = .zero
    @State private var isClosing: Bool = false

    private let cardCorner: CGFloat = 44
    private let peekScale: CGFloat = 0.88
    private let cardSpacingRatio: CGFloat = 0.62

    var body: some View {
        GeometryReader { geo in
            let cardWidth = min(geo.size.width * 0.72, 300)
            let cardHeight = min(geo.size.height * 0.62, 520)
            let spacing = cardWidth * cardSpacingRatio

            ZStack {
                switcherBackground
                    .ignoresSafeArea()

                if store.tabs.isEmpty {
                    Text("No tabs")
                        .foregroundStyle(.secondary)
                } else {
                    VStack(spacing: 18) {
                        Spacer(minLength: geo.size.height * 0.06)

                        ZStack {
                            ForEach(Array(store.tabs.enumerated()), id: \.element.id) { index, tab in
                                tabColumn(
                                    tab: tab,
                                    index: index,
                                    cardWidth: cardWidth,
                                    cardHeight: cardHeight,
                                    spacing: spacing
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .gesture(carouselGesture(spacing: spacing))

                        Spacer(minLength: 8)
                    }
                }
            }
        }
        .onAppear { syncFocusedIndex(animated: false) }
        .onChange(of: store.tabs.map(\.id)) { _, _ in
            syncFocusedIndex(animated: true)
        }
        .onChange(of: store.activeTabID) { _, _ in
            syncFocusedIndex(animated: true)
        }
    }

    // MARK: - Background

    private var switcherBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.12, blue: 0.18),
                    Color(red: 0.04, green: 0.05, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            // Soft “blurred wallpaper” blobs behind the carousel.
            Circle()
                .fill(Color.accentColor.opacity(0.22))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: -90, y: -140)
            Circle()
                .fill(Color(red: 0.25, green: 0.55, blue: 0.75).opacity(0.22))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 110, y: 80)
            Color.black.opacity(0.45)
        }
    }

    // MARK: - Card column (label above + tall preview)

    private func tabColumn(
        tab: BrowserTab,
        index: Int,
        cardWidth: CGFloat,
        cardHeight: CGFloat,
        spacing: CGFloat
    ) -> some View {
        let relative = CGFloat(index - focusedIndex)
        let progress = relative + (isClosing ? 0 : dragTranslation.width / max(spacing, 1))
        let absProgress = abs(progress)
        let scale = max(peekScale, 1 - absProgress * 0.12)
        let opacity = max(0.35, 1 - absProgress * 0.35)
        let x = progress * spacing
        let isFront = index == focusedIndex
        let closeY = isFront ? min(0, dragTranslation.height) : 0
        let closeOpacity = isFront
            ? Double(1 - min(abs(closeY) / 220, 0.9))
            : 1

        return VStack(spacing: 12) {
            tabLabel(for: tab)

            Button {
                guard isFront, !isClosing else { return }
                store.selectTab(tab.id)
            } label: {
                TabPreviewCard(tab: tab, cornerRadius: cardCorner)
                    .frame(width: cardWidth, height: cardHeight)
                    .shadow(color: .black.opacity(isFront ? 0.45 : 0.25), radius: isFront ? 28 : 14, y: 16)
            }
            .buttonStyle(.plain)
            .disabled(!isFront)
            .accessibilityLabel(tab.displayLabel)
            .accessibilityHint(isFront ? "Double tap to open. Swipe up to close." : "Swipe to bring to front")
        }
        .scaleEffect(scale)
        .opacity(opacity * closeOpacity)
        .offset(x: x, y: closeY)
        .zIndex(Double(1000 - abs(index - focusedIndex) * 10) + (isFront ? 50 : 0))
        .allowsHitTesting(isFront)
    }

    private func tabLabel(for tab: BrowserTab) -> some View {
        HStack(spacing: 8) {
            FaviconView(tab: tab)
            Text(tab.displayLabel)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Gestures

    private func carouselGesture(spacing: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                guard !store.tabs.isEmpty, !isClosing else { return }
                let horizontal = abs(value.translation.width) > abs(value.translation.height)
                if horizontal {
                    dragTranslation = CGSize(width: value.translation.width, height: 0)
                } else if value.translation.height < 0 {
                    // Swipe up on the front card to close.
                    dragTranslation = CGSize(width: 0, height: value.translation.height)
                } else {
                    dragTranslation = .zero
                }
            }
            .onEnded { value in
                guard !store.tabs.isEmpty, !isClosing else { return }
                let horizontal = abs(value.translation.width) >= abs(value.translation.height)

                if horizontal {
                    let projected = value.predictedEndTranslation.width
                    let delta = -Int((projected / max(spacing * 0.45, 1)).rounded())
                    let next = min(max(focusedIndex + delta, 0), store.tabs.count - 1)
                    withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.86)) {
                        focusedIndex = next
                        dragTranslation = .zero
                    }
                    store.activeTabID = store.tabs[next].id
                } else if value.translation.height < -120
                            || value.predictedEndTranslation.height < -220 {
                    closeFocusedTab()
                } else {
                    withAnimation(.interactiveSpring(response: 0.32, dampingFraction: 0.84)) {
                        dragTranslation = .zero
                    }
                }
            }
    }

    private func closeFocusedTab() {
        guard store.tabs.indices.contains(focusedIndex) else { return }
        let id = store.tabs[focusedIndex].id
        isClosing = true
        withAnimation(.easeIn(duration: 0.22)) {
            dragTranslation = CGSize(width: 0, height: -640)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            store.closeTab(id)
            dragTranslation = .zero
            isClosing = false
            syncFocusedIndex(animated: true)
        }
    }

    private func syncFocusedIndex(animated: Bool) {
        guard !store.tabs.isEmpty else {
            focusedIndex = 0
            return
        }
        let target: Int
        if let id = store.activeTabID,
           let idx = store.tabs.firstIndex(where: { $0.id == id }) {
            target = idx
        } else {
            target = min(focusedIndex, store.tabs.count - 1)
        }
        if animated {
            withAnimation(.interactiveSpring(response: 0.35, dampingFraction: 0.86)) {
                focusedIndex = target
            }
        } else {
            focusedIndex = target
        }
    }
}

// MARK: - Preview card

private struct TabPreviewCard: View {
    let tab: BrowserTab
    let cornerRadius: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(previewBackground)

            if tab.urlString.isEmpty {
                startPageContent
            } else {
                pagePreviewContent
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private var previewBackground: some ShapeStyle {
        if tab.urlString.isEmpty {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color(red: 0.78, green: 0.88, blue: 1.0),
                        Color(red: 0.92, green: 0.82, blue: 0.95),
                        Color(red: 0.98, green: 0.90, blue: 0.82)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        return AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color(red: 0.14, green: 0.16, blue: 0.22),
                    Color(red: 0.08, green: 0.09, blue: 0.12)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var startPageContent: some View {
        VStack(spacing: 16) {
            Text("R")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color.accentColor,
                            Color(red: 0.35, green: 0.45, blue: 0.95)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("New Tab")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.black.opacity(0.55))
        }
    }

    private var pagePreviewContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.12))
                .frame(height: 18)
                .padding(.horizontal, 18)
                .padding(.top, 28)

            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.white.opacity(i == 0 ? 0.18 : 0.08))
                    .frame(height: i == 0 ? 72 : 12)
                    .padding(.horizontal, 18)
            }

            Spacer()

            Text(tab.urlString)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .padding(.horizontal, 18)
                .padding(.bottom, 22)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct FaviconView: View {
    let tab: BrowserTab

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .fill(tab.urlString.isEmpty ? Color.accentColor.opacity(0.85) : Color.white.opacity(0.92))
            Text(tab.faviconGlyph)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundStyle(tab.urlString.isEmpty ? .white : .black.opacity(0.75))
        }
        .frame(width: 22, height: 22)
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
        )
    }
}

private extension BrowserTab {
    var displayLabel: String {
        if urlString.isEmpty { return "New Tab" }
        if !title.isEmpty, title != "New Tab" { return title }
        return displayHost
    }

    var faviconGlyph: String {
        if urlString.isEmpty { return "R" }
        let host = displayHost.replacingOccurrences(of: "www.", with: "")
        return String(host.prefix(1)).uppercased()
    }
}

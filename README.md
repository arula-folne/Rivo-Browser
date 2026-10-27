# Rivo Browser

One-handed iOS browser — an Arc Search–style replacement. Primary chrome lives at the bottom: **Tabs · New Tab · Settings**.

## Requirements

- macOS with **Xcode 15+** (SwiftUI / iOS 17 SDK)
- iOS **17.0+** Simulator or device
- Apple Developer signing team (set in Xcode for device runs)

## Open & run

1. Clone this repo.
2. Open `RivoBrowser.xcodeproj` in Xcode.
3. Select the **RivoBrowser** scheme and an iPhone simulator (or a device).
4. If needed, set **Signing & Capabilities → Team** for your Apple ID.
5. Press **Run** (⌘R).

On launch you should land on **New Tab** with the search field focused and the keyboard up. Use the bottom bar only to switch **Tabs**, open **New Tab**, or open **Settings**.

## Skeleton layout

```
RivoBrowser.xcodeproj
RivoBrowser/
  RivoBrowserApp.swift
  Models/          # Tab, history, chrome mode
  Engine/          # BrowserEngine protocol + WKWebView impl
  State/           # In-memory BrowserStore
  Views/           # Shell, chrome, new tab, tabs switcher, settings
  Resources/       # Assets
  Info.plist
```

### UX (this PR)

| Surface | Behavior |
|--------|----------|
| Launch / New Tab | Search history list + bottom search bar + keyboard |
| Tabs | Arc / App Switcher carousel; swipe up to close, tap to open |
| Settings | Placeholder |
| Bottom chrome | Only Tabs, New Tab, Settings |

Tabs and search history are **in-memory stubs** for now.

## Engine: WebKit by design

Rendering goes through a thin `BrowserEngine` protocol with a single implementation: `WKWebViewBrowserEngine` (system WebKit / `WKWebView`).

**App Store path:** Rivo targets App Store iOS, so the page engine is **WebKit only** — matching Apple’s requirement that third-party browsers use the system WebKit stack. There is no Chromium/Blink embed planned for this product.

## License

GPL-3.0 — see [LICENSE](LICENSE).

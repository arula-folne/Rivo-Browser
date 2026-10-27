import SwiftUI

/// Bottom-anchored search/entry field for one-handed typing.
struct SearchBarView: View {
    @EnvironmentObject private var store: BrowserStore
    @FocusState private var isFocused: Bool
    var placeholder: String = "Search or enter URL"

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $store.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .keyboardType(.webSearch)
                .submitLabel(.go)
                .focused($isFocused)
                .onSubmit {
                    store.submitSearch()
                    isFocused = false
                }

            if !store.searchText.isEmpty {
                Button {
                    store.searchText = ""
                    isFocused = true
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .onChange(of: store.searchFocusToken) { _, _ in
            // Defer so the field exists in the hierarchy before focusing.
            DispatchQueue.main.async {
                isFocused = true
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                isFocused = true
            }
        }
    }
}

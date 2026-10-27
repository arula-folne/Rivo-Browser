import Foundation

struct BrowserTab: Identifiable, Equatable {
    let id: UUID
    var title: String
    var urlString: String
    var isLoading: Bool

    init(
        id: UUID = UUID(),
        title: String = "New Tab",
        urlString: String = "",
        isLoading: Bool = false
    ) {
        self.id = id
        self.title = title
        self.urlString = urlString
        self.isLoading = isLoading
    }

    var displayHost: String {
        guard let url = URL(string: urlString), let host = url.host, !host.isEmpty else {
            return "New Tab"
        }
        return host
    }
}

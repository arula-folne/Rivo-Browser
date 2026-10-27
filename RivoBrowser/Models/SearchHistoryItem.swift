import Foundation

struct SearchHistoryItem: Identifiable, Equatable {
    let id: UUID
    var query: String
    var urlString: String
    var visitedAt: Date

    init(
        id: UUID = UUID(),
        query: String,
        urlString: String,
        visitedAt: Date = Date()
    ) {
        self.id = id
        self.query = query
        self.urlString = urlString
        self.visitedAt = visitedAt
    }
}

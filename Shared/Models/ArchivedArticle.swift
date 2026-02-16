import Foundation
import SwiftData

enum ArchiveStatus: String, Codable {
    case pending
    case archiving
    case archived
    case failed
}

@Model
final class ArchivedArticle {
    @Attribute(.unique) var id: UUID
    var originalURL: String
    var archiveURL: String
    var title: String?
    var siteName: String?
    var status: ArchiveStatus
    var dateAdded: Date
    var dateArchived: Date?
    var lastAccessed: Date?
    var isFavorite: Bool
    var isRead: Bool

    init(
        originalURL: String,
        archiveURL: String = "",
        title: String? = nil,
        status: ArchiveStatus = .pending
    ) {
        self.id = UUID()
        self.originalURL = originalURL
        self.archiveURL = archiveURL
        self.title = title
        self.siteName = URL(string: originalURL)?.host
        self.status = status
        self.dateAdded = Date()
        self.isFavorite = false
        self.isRead = false
    }
}

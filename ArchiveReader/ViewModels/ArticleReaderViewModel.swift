import SwiftUI
import Observation

@Observable
final class ArticleReaderViewModel {
    private let article: ArchivedArticle
    private let archiveService = ArchiveService()

    var displayURL: URL?
    var isArchiving = false
    var archivingStatus = ""
    var error: String?

    init(article: ArchivedArticle) {
        self.article = article

        // If already archived, use the saved URL
        if article.status == .archived, !article.archiveURL.isEmpty {
            self.displayURL = URL(string: article.archiveURL)
        }
    }

    func startArchiving() {
        guard let originalURL = URL(string: article.originalURL) else {
            error = "Invalid URL"
            return
        }

        // Already have a display URL
        if displayURL != nil { return }

        isArchiving = true
        error = nil
        article.status = .archiving

        Task {
            do {
                archivingStatus = "Checking for existing archive..."

                if let existingURL = await archiveService.checkExistingArchive(for: originalURL) {
                    await MainActor.run {
                        displayURL = existingURL
                        article.archiveURL = existingURL.absoluteString
                        article.status = .archived
                        article.dateArchived = Date()
                        isArchiving = false
                    }
                    return
                }

                archivingStatus = "Submitting to archive.ph..."

                let submissionURL = try await archiveService.submissionURL(for: originalURL)
                await MainActor.run {
                    displayURL = submissionURL
                    article.archiveURL = submissionURL.absoluteString
                    article.status = .archived
                    article.dateArchived = Date()
                    isArchiving = false
                }
            } catch {
                await MainActor.run {
                    self.error = error.localizedDescription
                    article.status = .failed
                    isArchiving = false
                }
            }
        }
    }
}

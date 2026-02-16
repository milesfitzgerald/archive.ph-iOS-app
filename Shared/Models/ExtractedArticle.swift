import Foundation

struct ExtractedArticle {
    let title: String
    let byline: String
    let content: String
    let excerpt: String
    let siteName: String
    let length: Int

    var isEmpty: Bool {
        content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

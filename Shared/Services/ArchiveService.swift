import Foundation

actor ArchiveService {
    private let baseURL = "https://archive.ph"

    enum ArchiveError: LocalizedError {
        case invalidURL
        case networkError(Error)
        case archiveFailed

        var errorDescription: String? {
            switch self {
            case .invalidURL: return "Invalid URL format"
            case .networkError(let error): return "Network error: \(error.localizedDescription)"
            case .archiveFailed: return "Failed to archive the page"
            }
        }
    }

    /// Check if a URL has already been archived on archive.ph.
    /// Returns the archive URL if one exists, nil otherwise.
    func checkExistingArchive(for url: URL) async -> URL? {
        let checkURLString = "\(baseURL)/newest/\(url.absoluteString)"
        guard let requestURL = URL(string: checkURLString) else { return nil }

        var request = URLRequest(url: requestURL)
        request.httpMethod = "HEAD"
        request.timeoutInterval = 10

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse,
               http.statusCode == 200,
               let finalURL = http.url,
               finalURL.absoluteString.contains("archive.ph/") {
                return finalURL
            }
        } catch {
            // Not found or network issue
        }
        return nil
    }

    /// Build the archive.ph submission URL for a given page URL.
    /// Since archive.ph has no public API, this URL loads the web
    /// interface which either shows an existing snapshot or starts archiving.
    func submissionURL(for url: URL) throws -> URL {
        guard let encoded = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let result = URL(string: "\(baseURL)/?url=\(encoded)")
        else {
            throw ArchiveError.invalidURL
        }
        return result
    }

    /// Build the "newest archive" URL which redirects to the latest snapshot.
    func newestURL(for url: URL) -> URL? {
        URL(string: "\(baseURL)/newest/\(url.absoluteString)")
    }
}

import SwiftUI
import Observation

@Observable
final class DeepLinkHandler {
    var pendingArchiveURL: URL?
    var shouldNavigateToReader = false

    func handle(url: URL) {
        guard url.scheme == Constants.urlScheme,
              url.host == "archive",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let urlParam = components.queryItems?.first(where: { $0.name == "url" })?.value,
              let targetURL = URL(string: urlParam)
        else { return }

        pendingArchiveURL = targetURL
        shouldNavigateToReader = true
    }

    func clearPending() {
        pendingArchiveURL = nil
        shouldNavigateToReader = false
    }
}

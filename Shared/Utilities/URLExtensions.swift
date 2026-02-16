import Foundation

extension URL {
    var isArchiveURL: Bool {
        guard let host = host?.lowercased() else { return false }
        return host.contains("archive.ph")
            || host.contains("archive.today")
            || host.contains("archive.is")
    }
}

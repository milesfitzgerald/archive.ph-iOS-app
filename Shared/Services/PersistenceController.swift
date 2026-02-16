import SwiftData
import Foundation

enum PersistenceController {
    static var appGroupContainerURL: URL {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: Constants.appGroupIdentifier
        )!
    }

    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([ArchivedArticle.self])

        let config = ModelConfiguration(
            schema: schema,
            url: appGroupContainerURL.appendingPathComponent("ArchiveReader.store"),
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}

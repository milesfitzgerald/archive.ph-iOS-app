import SwiftUI
import SwiftData

@main
struct ArchiveReaderApp: App {
    @State private var deepLinkHandler = DeepLinkHandler()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(deepLinkHandler)
                .onOpenURL { url in
                    deepLinkHandler.handle(url: url)
                }
        }
        .modelContainer(PersistenceController.sharedModelContainer)
    }
}

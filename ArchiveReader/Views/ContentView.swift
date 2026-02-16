import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(DeepLinkHandler.self) private var deepLinkHandler
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ArchivedArticle.dateAdded, order: .reverse)
    private var articles: [ArchivedArticle]

    @State private var selectedArticle: ArchivedArticle?
    @State private var showingManualEntry = false

    var body: some View {
        NavigationStack {
            Group {
                if articles.isEmpty {
                    EmptyStateView()
                } else {
                    ArticleListView(
                        articles: articles,
                        onSelect: { selectedArticle = $0 },
                        onDelete: { modelContext.delete($0) }
                    )
                }
            }
            .navigationTitle("Archive Reader")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingManualEntry = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingManualEntry) {
                ManualArchiveView { article in
                    selectedArticle = article
                }
            }
            .navigationDestination(item: $selectedArticle) { article in
                ArticleReaderView(article: article)
            }
        }
        .onChange(of: deepLinkHandler.shouldNavigateToReader) { _, shouldNavigate in
            guard shouldNavigate, let url = deepLinkHandler.pendingArchiveURL else { return }
            handleIncomingURL(url)
            deepLinkHandler.clearPending()
        }
    }

    private func handleIncomingURL(_ url: URL) {
        if let existing = articles.first(where: { $0.originalURL == url.absoluteString }) {
            selectedArticle = existing
        } else {
            let article = ArchivedArticle(originalURL: url.absoluteString)
            modelContext.insert(article)
            try? modelContext.save()
            selectedArticle = article
        }
    }
}

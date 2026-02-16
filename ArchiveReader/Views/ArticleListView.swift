import SwiftUI

struct ArticleListView: View {
    let articles: [ArchivedArticle]
    let onSelect: (ArchivedArticle) -> Void
    let onDelete: (ArchivedArticle) -> Void

    @State private var searchText = ""

    private var filtered: [ArchivedArticle] {
        guard !searchText.isEmpty else { return articles }
        return articles.filter { article in
            article.title?.localizedCaseInsensitiveContains(searchText) == true
                || article.siteName?.localizedCaseInsensitiveContains(searchText) == true
                || article.originalURL.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            ForEach(filtered) { article in
                ArticleRowView(article: article)
                    .contentShape(Rectangle())
                    .onTapGesture { onSelect(article) }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(article)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            article.isFavorite.toggle()
                        } label: {
                            Label(
                                article.isFavorite ? "Unfavorite" : "Favorite",
                                systemImage: article.isFavorite ? "star.slash" : "star"
                            )
                        }
                        .tint(.yellow)
                    }
            }
        }
        .listStyle(.plain)
        .searchable(text: $searchText, prompt: "Search articles")
    }
}

import SwiftUI
import SwiftData

struct ManualArchiveView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var onArticleCreated: (ArchivedArticle) -> Void

    @State private var urlText = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("https://example.com/article", text: $urlText)
                        .textContentType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                } header: {
                    Text("Article URL")
                } footer: {
                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Button("Archive") {
                        archive()
                    }
                    .disabled(urlText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func archive() {
        var input = urlText.trimmingCharacters(in: .whitespacesAndNewlines)

        // Prepend https:// if missing
        if !input.lowercased().hasPrefix("http://") && !input.lowercased().hasPrefix("https://") {
            input = "https://\(input)"
        }

        guard let url = URL(string: input), url.host != nil else {
            errorMessage = "Please enter a valid URL."
            return
        }

        let article = ArchivedArticle(originalURL: url.absoluteString)
        modelContext.insert(article)
        try? modelContext.save()
        dismiss()
        onArticleCreated(article)
    }
}

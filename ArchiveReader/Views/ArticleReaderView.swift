import SwiftUI

struct ArticleReaderView: View {
    @Bindable var article: ArchivedArticle
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: ArticleReaderViewModel
    @State private var isLoading = true
    @State private var progress: Double = 0
    @State private var pageTitle: String?
    @State private var showShareSheet = false

    // Reader mode state
    @State private var isReaderModeActive = false
    @State private var extractedArticle: ExtractedArticle?
    @State private var showReaderSettings = false
    @State private var webViewStore = WebViewStore()
    @State private var readerExtractionFailed = false

    private var readerSettings = ReaderSettings.shared

    init(article: ArchivedArticle) {
        self.article = article
        self._viewModel = State(initialValue: ArticleReaderViewModel(article: article))
    }

    var body: some View {
        ZStack {
            if viewModel.displayURL != nil {
                ReaderWebView(
                    onMessage: { handleReaderMessage($0) },
                    onFinishedLoading: { onPageLoaded() },
                    onProgress: { progress = $0 },
                    onTitle: { pageTitle = $0 },
                    isLoading: $isLoading,
                    store: webViewStore
                )
                .ignoresSafeArea(edges: .bottom)
            } else if viewModel.isArchiving {
                archivingView
            } else if let errorMessage = viewModel.error {
                errorView(errorMessage)
            }

            // Progress bar
            if isLoading, viewModel.displayURL != nil {
                VStack {
                    ProgressView(value: progress).tint(.blue)
                    Spacer()
                }
            }
        }
        .navigationTitle(article.title ?? article.siteName ?? "Article")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Reader mode toggle
                Button {
                    toggleReaderMode()
                } label: {
                    Image(systemName: isReaderModeActive ? "globe" : "doc.text.image")
                }
                .disabled(viewModel.displayURL == nil)

                // Reader settings (only in reader mode)
                if isReaderModeActive {
                    Button {
                        showReaderSettings = true
                    } label: {
                        Image(systemName: "textformat.size")
                    }
                    .popover(isPresented: $showReaderSettings) {
                        ReaderSettingsPopover(
                            settings: readerSettings,
                            onSettingsChanged: { regenerateReaderHTML() }
                        )
                    }
                }

                // Favorite
                Button {
                    article.isFavorite.toggle()
                } label: {
                    Image(systemName: article.isFavorite ? "star.fill" : "star")
                }
                .tint(article.isFavorite ? .yellow : .primary)

                // Share
                Button {
                    showShareSheet = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = viewModel.displayURL {
                ShareSheet(items: [url])
            }
        }
        .onChange(of: pageTitle) { _, newTitle in
            if let title = newTitle, !title.isEmpty, article.title == nil {
                article.title = title
            }
        }
        .onAppear {
            article.lastAccessed = Date()
            article.isRead = true
            if article.status != .archived {
                viewModel.startArchiving()
            }
        }
        // When the display URL becomes available, load it in the WebView.
        .onChange(of: viewModel.displayURL) { _, newURL in
            if let url = newURL {
                webViewStore.load(url)
            }
        }
    }

    // MARK: - Reader Mode Logic

    private func toggleReaderMode() {
        if isReaderModeActive {
            // Exit reader mode → reload original archive page
            isReaderModeActive = false
            readerExtractionFailed = false
            if let url = viewModel.displayURL {
                webViewStore.load(url)
            }
        } else if let extracted = extractedArticle {
            // Already extracted → show reader immediately
            showReaderContent(extracted)
        } else {
            // Need to extract → inject JS
            webViewStore.injectAndExtract()
        }
    }

    private func handleReaderMessage(_ message: ReaderMessage) {
        switch message {
        case .bridgeReady:
            break

        case .contentExtracted(let extracted):
            if extracted.isEmpty {
                readerExtractionFailed = true
            } else {
                extractedArticle = extracted
                showReaderContent(extracted)
                // Update article title if we didn't have one
                if article.title == nil, !extracted.title.isEmpty {
                    article.title = extracted.title
                }
            }

        case .extractionError:
            readerExtractionFailed = true

        case .readabilityCheck:
            break
        }
    }

    private func showReaderContent(_ extracted: ExtractedArticle) {
        let html = ReaderModeService.generateReaderHTML(
            article: extracted,
            settings: readerSettings
        )
        isReaderModeActive = true
        webViewStore.loadHTML(html, baseURL: viewModel.displayURL)
    }

    private func regenerateReaderHTML() {
        guard let extracted = extractedArticle else { return }
        let html = ReaderModeService.generateReaderHTML(
            article: extracted,
            settings: readerSettings
        )
        webViewStore.loadHTML(html, baseURL: viewModel.displayURL)
    }

    private func onPageLoaded() {
        // After the original archive.ph page loads, auto-load into the WebView
        // (nothing extra needed here — page is already displayed)
    }

    // MARK: - Subviews

    private var archivingView: some View {
        VStack(spacing: 20) {
            ProgressView().scaleEffect(1.5)
            Text("Archiving Article...").font(.headline)
            Text(viewModel.archivingStatus)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.orange)
            Text("Failed to Archive").font(.headline)
            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Retry") { viewModel.startArchiving() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - UIActivityViewController wrapper

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

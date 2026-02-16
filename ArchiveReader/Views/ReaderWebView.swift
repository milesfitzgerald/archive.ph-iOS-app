import SwiftUI
import WebKit
import Observation

// MARK: - Messages from JavaScript

enum ReaderMessage {
    case bridgeReady
    case contentExtracted(ExtractedArticle)
    case extractionError(String)
    case readabilityCheck(Bool)
}

// MARK: - WebViewStore (imperative access to WKWebView)

@Observable
final class WebViewStore {
    var webView: WKWebView?

    /// Inject the JS libraries and trigger article extraction.
    func injectAndExtract() {
        guard let webView, let script = ReaderModeService.injectionScript else { return }

        webView.evaluateJavaScript(script) { [weak self] _, error in
            if let error {
                print("[ReaderWebView] JS injection error: \(error.localizedDescription)")
                return
            }
            self?.webView?.evaluateJavaScript("window.ReaderBridge.extractContent()") { _, error in
                if let error {
                    print("[ReaderWebView] Extraction call error: \(error.localizedDescription)")
                }
            }
        }
    }

    /// Reload the current page (used to exit reader mode).
    func reload() {
        webView?.reload()
    }

    /// Load a specific URL.
    func load(_ url: URL) {
        webView?.load(URLRequest(url: url))
    }

    /// Load an HTML string with an optional base URL.
    func loadHTML(_ html: String, baseURL: URL?) {
        webView?.loadHTMLString(html, baseURL: baseURL)
    }
}

// MARK: - ReaderWebView

struct ReaderWebView: UIViewRepresentable {
    /// Callback for reader-mode messages from JS.
    var onMessage: ((ReaderMessage) -> Void)?
    /// Callback when navigation finishes.
    var onFinishedLoading: (() -> Void)?
    /// Callback for progress updates.
    var onProgress: ((Double) -> Void)?
    /// Callback for title updates.
    var onTitle: ((String?) -> Void)?

    @Binding var isLoading: Bool

    /// Reference so the parent can call imperative methods.
    let store: WebViewStore

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let userCC = WKUserContentController()
        userCC.add(context.coordinator, name: "readerMode")

        let config = WKWebViewConfiguration()
        config.userContentController = userCC
        config.allowsInlineMediaPlayback = true

        let wv = WKWebView(frame: .zero, configuration: config)
        wv.navigationDelegate = context.coordinator
        wv.allowsBackForwardNavigationGestures = true

        store.webView = wv
        context.coordinator.observe(wv)
        return wv
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Intentionally empty — all loading is driven imperatively via WebViewStore.
    }

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: ReaderWebView
        private var progressObs: NSKeyValueObservation?
        private var titleObs: NSKeyValueObservation?

        init(_ parent: ReaderWebView) { self.parent = parent }

        func observe(_ wv: WKWebView) {
            progressObs = wv.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.onProgress?(wv.estimatedProgress) }
            }
            titleObs = wv.observe(\.title, options: .new) { [weak self] wv, _ in
                DispatchQueue.main.async { self?.parent.onTitle?(wv.title) }
            }
        }

        // MARK: WKNavigationDelegate

        func webView(_ wv: WKWebView, didStartProvisionalNavigation n: WKNavigation!) {
            DispatchQueue.main.async { self.parent.isLoading = true }
        }

        func webView(_ wv: WKWebView, didFinish n: WKNavigation!) {
            DispatchQueue.main.async {
                self.parent.isLoading = false
                self.parent.onFinishedLoading?()
            }
        }

        func webView(_ wv: WKWebView, didFail n: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }

        func webView(_ wv: WKWebView, didFailProvisionalNavigation n: WKNavigation!, withError error: Error) {
            DispatchQueue.main.async { self.parent.isLoading = false }
        }

        // MARK: WKScriptMessageHandler

        func userContentController(
            _ controller: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "readerMode",
                  let body = message.body as? [String: Any],
                  let type = body["type"] as? String
            else { return }

            DispatchQueue.main.async { [weak self] in
                switch type {
                case "bridgeReady":
                    self?.parent.onMessage?(.bridgeReady)

                case "contentExtracted":
                    let article = ExtractedArticle(
                        title:    body["title"]    as? String ?? "",
                        byline:   body["byline"]   as? String ?? "",
                        content:  body["content"]  as? String ?? "",
                        excerpt:  body["excerpt"]  as? String ?? "",
                        siteName: body["siteName"] as? String ?? "",
                        length:   body["length"]   as? Int    ?? 0
                    )
                    self?.parent.onMessage?(.contentExtracted(article))

                case "extractionError":
                    let err = body["error"] as? String ?? "Unknown error"
                    self?.parent.onMessage?(.extractionError(err))

                case "readabilityCheck":
                    let ok = body["isReadable"] as? Bool ?? false
                    self?.parent.onMessage?(.readabilityCheck(ok))

                default:
                    break
                }
            }
        }

        deinit {
            progressObs?.invalidate()
            titleObs?.invalidate()
        }
    }
}

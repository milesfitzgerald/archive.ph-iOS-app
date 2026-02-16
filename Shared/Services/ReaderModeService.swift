import Foundation

enum ReaderModeService {

    // MARK: - HTML Generation

    /// Build a self-contained reader-mode HTML page.
    static func generateReaderHTML(
        article: ExtractedArticle,
        settings: ReaderSettings
    ) -> String {
        let theme = settings.theme
        let fontSize = settings.fontSize

        return """
        <!DOCTYPE html>
        <html lang="en">
        <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=3.0, user-scalable=yes">
        <title>\(escapeHTML(article.title))</title>
        <style>
        :root {
            --bg:    \(theme.backgroundColor);
            --fg:    \(theme.textColor);
            --link:  \(theme.linkColor);
            --border:\(theme.borderColor);
            --code:  \(theme.codeBgColor);
            --fs:    \(fontSize.rawValue)px;
            --lh:    \(fontSize.lineHeight)px;
        }
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", Helvetica, Arial, sans-serif;
            font-size: var(--fs);
            line-height: var(--lh);
            color: var(--fg);
            background: var(--bg);
            padding: 20px;
            padding-bottom: 100px;
            -webkit-text-size-adjust: 100%;
        }
        article { max-width: 680px; margin: 0 auto; }
        header { margin-bottom: 32px; padding-bottom: 16px; border-bottom: 1px solid var(--border); }
        h1.title { font-size: 1.75em; font-weight: 700; line-height: 1.2; margin-bottom: 12px; }
        .byline { font-size: 0.9em; opacity: 0.65; }
        .content h1,.content h2,.content h3,
        .content h4,.content h5,.content h6 { font-weight: 600; line-height: 1.3; margin-top: 1.5em; margin-bottom: 0.5em; }
        .content h2 { font-size: 1.4em; }
        .content h3 { font-size: 1.2em; }
        .content h4 { font-size: 1.1em; }
        .content p { margin: 0 0 1em; }
        .content a { color: var(--link); text-decoration: underline; }
        .content img { max-width: 100%; height: auto; border-radius: 8px; margin: 1em 0; display: block; }
        .content figure { margin: 1.5em 0; }
        .content figcaption { font-size: 0.85em; opacity: 0.65; text-align: center; margin-top: 8px; }
        .content blockquote {
            margin: 1em 0; padding: 0.5em 0 0.5em 1em;
            border-left: 3px solid var(--link); opacity: 0.9;
        }
        .content pre, .content code {
            font-family: "SF Mono", Menlo, Monaco, monospace; font-size: 0.9em;
        }
        .content pre {
            background: var(--code); padding: 1em; border-radius: 8px; overflow-x: auto; margin: 1em 0;
        }
        .content code {
            background: var(--code); padding: 0.15em 0.35em; border-radius: 4px;
        }
        .content pre code { background: none; padding: 0; }
        .content ul, .content ol { margin: 1em 0; padding-left: 1.5em; }
        .content li { margin: 0.4em 0; }
        .content table { width: 100%; border-collapse: collapse; margin: 1em 0; }
        .content th, .content td { padding: 8px 12px; border: 1px solid var(--border); text-align: left; }
        .content th { background: var(--code); font-weight: 600; }
        .content hr { border: none; border-top: 1px solid var(--border); margin: 2em 0; }
        </style>
        </head>
        <body>
        <article>
            <header>
                <h1 class="title">\(escapeHTML(article.title))</h1>
                \(article.byline.isEmpty ? "" : "<p class=\"byline\">\(escapeHTML(article.byline))</p>")
            </header>
            <div class="content">\(article.content)</div>
        </article>
        </body>
        </html>
        """
    }

    // MARK: - JavaScript Loading

    /// Concatenated JS payload: Readability + Readability-readerable + DOMPurify + ReaderBridge.
    static var injectionScript: String? {
        guard let readability = loadJS("Readability"),
              let readerable = loadJS("Readability-readerable"),
              let purify = loadJS("Purify.min"),
              let bridge = loadJS("ReaderBridge")
        else { return nil }

        return [readability, readerable, purify, bridge].joined(separator: "\n")
    }

    // MARK: - Helpers

    private static func loadJS(_ name: String) -> String? {
        // JS files are bundled as a folder reference under "JavaScript/"
        if let url = Bundle.main.url(forResource: name, withExtension: "js", subdirectory: "JavaScript"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            return content
        }
        // Fallback: check root of bundle
        if let url = Bundle.main.url(forResource: name, withExtension: "js"),
           let content = try? String(contentsOf: url, encoding: .utf8) {
            return content
        }
        return nil
    }

    private static func escapeHTML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
    }
}

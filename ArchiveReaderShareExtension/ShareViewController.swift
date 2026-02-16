import UIKit
import SwiftUI
import UniformTypeIdentifiers
import SwiftData

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        extractSharedURL { [weak self] url in
            guard let self, let url else {
                self?.close()
                return
            }
            self.setupUI(with: url)
        }
    }

    // MARK: - URL Extraction

    private func extractSharedURL(completion: @escaping (URL?) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first,
              provider.hasItemConformingToTypeIdentifier(UTType.url.identifier)
        else {
            completion(nil)
            return
        }

        provider.loadItem(forTypeIdentifier: UTType.url.identifier) { item, _ in
            DispatchQueue.main.async {
                if let url = item as? URL {
                    completion(url)
                } else if let data = item as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil) {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
    }

    // MARK: - UI

    private func setupUI(with url: URL) {
        let shareView = ShareExtensionView(
            url: url,
            onSave: { [weak self] in self?.saveArticle(url: url) },
            onCancel: { [weak self] in self?.close() }
        )

        let host = UIHostingController(rootView: shareView)
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        host.didMove(toParent: self)
    }

    // MARK: - Save & Open

    private func saveArticle(url: URL) {
        Task {
            let container = PersistenceController.sharedModelContainer
            let context = ModelContext(container)

            let urlString = url.absoluteString
            let descriptor = FetchDescriptor<ArchivedArticle>(
                predicate: #Predicate { $0.originalURL == urlString }
            )

            if (try? context.fetch(descriptor).first) == nil {
                let article = ArchivedArticle(originalURL: urlString)
                context.insert(article)
                try? context.save()
            }

            openMainApp(with: url)
        }
    }

    private func openMainApp(with url: URL) {
        guard let encoded = url.absoluteString
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let appURL = URL(string: "\(Constants.urlScheme)://archive?url=\(encoded)")
        else {
            close()
            return
        }

        // Walk the responder chain to reach UIApplication.open(_:)
        var responder: UIResponder? = self
        while let r = responder {
            if let app = r as? UIApplication {
                app.open(appURL)
                break
            }
            responder = r.next
        }
        close()
    }

    private func close() {
        extensionContext?.completeRequest(returningItems: nil)
    }
}

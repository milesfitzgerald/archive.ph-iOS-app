import SwiftUI

struct ArticleRowView: View {
    let article: ArchivedArticle

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                statusIcon
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(article.title ?? article.siteName ?? "Untitled")
                    .font(.headline)
                    .lineLimit(2)

                Text(article.siteName ?? "")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: 6) {
                    Text(article.dateAdded, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)

                    if article.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                    }

                    if article.isRead {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Status Helpers

    private var statusColor: Color {
        switch article.status {
        case .pending:   return .orange
        case .archiving: return .blue
        case .archived:  return .green
        case .failed:    return .red
        }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch article.status {
        case .pending:
            Image(systemName: "clock.fill")
        case .archiving:
            ProgressView().scaleEffect(0.8)
        case .archived:
            Image(systemName: "checkmark.circle.fill")
        case .failed:
            Image(systemName: "exclamationmark.triangle.fill")
        }
    }
}

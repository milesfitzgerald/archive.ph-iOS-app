import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Archived Articles")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Share articles from Safari or other apps\nto save them to your archive.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 12) {
                instructionRow(number: 1, text: "Find an article in Safari")
                instructionRow(number: 2, text: "Tap the Share button")
                instructionRow(number: 3, text: "Select \"Archive Reader\"")
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }

    private func instructionRow(number: Int, text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .frame(width: 24, height: 24)
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
        }
    }
}

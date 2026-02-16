import SwiftUI

struct ShareExtensionView: View {
    let url: URL
    let onSave: () -> Void
    let onCancel: () -> Void

    @State private var isSaving = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Preview card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "archivebox.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Archive Article")
                            .font(.headline)
                    }

                    Text(url.host ?? url.absoluteString)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    Text(url.absoluteString)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Spacer()

                // Actions
                VStack(spacing: 12) {
                    Button {
                        isSaving = true
                        onSave()
                    } label: {
                        HStack {
                            if isSaving {
                                ProgressView().tint(.white)
                            } else {
                                Image(systemName: "arrow.down.doc.fill")
                            }
                            Text("Save to Archive")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(isSaving)

                    Button("Cancel", action: onCancel)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .navigationTitle("Archive Reader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
            }
        }
    }
}

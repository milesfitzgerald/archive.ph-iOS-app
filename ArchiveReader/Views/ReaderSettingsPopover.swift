import SwiftUI

struct ReaderSettingsPopover: View {
    var settings: ReaderSettings
    var onSettingsChanged: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Theme picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Theme")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    ForEach(ReaderTheme.allCases, id: \.self) { theme in
                        ThemeButton(
                            theme: theme,
                            isSelected: settings.theme == theme
                        ) {
                            settings.theme = theme
                            onSettingsChanged()
                        }
                    }
                }
            }

            Divider()

            // Font size picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Font Size")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    ForEach(ReaderFontSize.allCases, id: \.self) { size in
                        FontSizeButton(
                            size: size,
                            isSelected: settings.fontSize == size
                        ) {
                            settings.fontSize = size
                            onSettingsChanged()
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 280)
    }
}

// MARK: - Theme Button

private struct ThemeButton: View {
    let theme: ReaderTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Circle()
                    .fill(theme.previewColor)
                    .overlay(
                        Circle().stroke(
                            isSelected ? Color.accentColor : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                    )
                    .shadow(color: .black.opacity(0.08), radius: 2, y: 1)
                    .frame(width: 44, height: 44)

                Text(theme.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Font Size Button

private struct FontSizeButton: View {
    let size: ReaderFontSize
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(size.displayName)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .frame(width: 40, height: 36)
                .background(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

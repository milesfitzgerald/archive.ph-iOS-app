import Foundation
import SwiftUI
import Observation

// MARK: - Theme

enum ReaderTheme: String, CaseIterable, Codable {
    case light
    case dark
    case sepia

    var displayName: String {
        switch self {
        case .light: "Light"
        case .dark:  "Dark"
        case .sepia: "Sepia"
        }
    }

    var backgroundColor: String {
        switch self {
        case .light: "#FFFFFF"
        case .dark:  "#1C1C1E"
        case .sepia: "#F4ECD8"
        }
    }

    var textColor: String {
        switch self {
        case .light: "#1C1C1E"
        case .dark:  "#F5F5F5"
        case .sepia: "#5B4636"
        }
    }

    var linkColor: String {
        switch self {
        case .light: "#007AFF"
        case .dark:  "#0A84FF"
        case .sepia: "#8B6914"
        }
    }

    var borderColor: String {
        switch self {
        case .light: "#E5E5E5"
        case .dark:  "#3A3A3C"
        case .sepia: "#D5C9AE"
        }
    }

    var codeBgColor: String {
        switch self {
        case .light: "#F5F5F5"
        case .dark:  "#2C2C2E"
        case .sepia: "#EAE0C8"
        }
    }

    /// SwiftUI color for the preview circle in the settings popover.
    var previewColor: Color {
        Color(hex: backgroundColor)
    }
}

// MARK: - Font Size

enum ReaderFontSize: Int, CaseIterable, Codable {
    case xsmall = 14
    case small  = 16
    case medium = 18
    case large  = 20
    case xlarge = 24

    var displayName: String {
        switch self {
        case .xsmall: "XS"
        case .small:  "S"
        case .medium: "M"
        case .large:  "L"
        case .xlarge: "XL"
        }
    }

    var lineHeight: Double {
        Double(rawValue) * 1.6
    }
}

// MARK: - Settings (singleton, persisted)

@Observable
final class ReaderSettings {
    private static let themeKey = "readerTheme"
    private static let fontSizeKey = "readerFontSize"

    static let shared = ReaderSettings()

    var theme: ReaderTheme {
        didSet { save() }
    }

    var fontSize: ReaderFontSize {
        didSet { save() }
    }

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.themeKey),
           let t = ReaderTheme(rawValue: raw) {
            theme = t
        } else {
            theme = .light
        }

        let rawSize = UserDefaults.standard.integer(forKey: Self.fontSizeKey)
        if rawSize > 0, let s = ReaderFontSize(rawValue: rawSize) {
            fontSize = s
        } else {
            fontSize = .medium
        }
    }

    private func save() {
        UserDefaults.standard.set(theme.rawValue, forKey: Self.themeKey)
        UserDefaults.standard.set(fontSize.rawValue, forKey: Self.fontSizeKey)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

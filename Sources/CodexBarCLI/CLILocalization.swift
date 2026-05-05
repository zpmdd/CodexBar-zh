import CodexBarCore
import Foundation

private struct CLIXCStringCatalog: Decodable, Sendable {
    struct Entry: Decodable, Sendable {
        struct Localization: Decodable, Sendable {
            struct StringUnit: Decodable, Sendable {
                let value: String
            }

            let stringUnit: StringUnit?
        }

        let localizations: [String: Localization]?
    }

    let strings: [String: Entry]
}

private final class CLIStringCatalog: @unchecked Sendable {
    static let shared = CLIStringCatalog(bundle: .module)

    private let catalog: CLIXCStringCatalog?
    private let bundle: Bundle

    init(bundle: Bundle) {
        self.bundle = bundle
        guard let url = bundle.url(forResource: "Localizable", withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url)
        else {
            self.catalog = nil
            return
        }
        self.catalog = try? JSONDecoder().decode(CLIXCStringCatalog.self, from: data)
    }

    func localized(_ key: String, languageIdentifier: String) -> String? {
        guard languageIdentifier != "en" else { return key }
        let localized = String(
            localized: String.LocalizationValue(key),
            table: "Localizable",
            bundle: self.bundle,
            locale: Locale(identifier: languageIdentifier))
        if localized != key {
            return localized
        }
        return self.catalog?.strings[key]?.localizations?[languageIdentifier]?.stringUnit?.value
    }
}

enum CLIL10n {
    static var usesChinese: Bool {
        AppLanguageRuntime.resolvedPreference().resolvedLocalizationIdentifier() == "zh-Hans"
    }

    static func tr(_ key: String) -> String {
        let preference = AppLanguageRuntime.resolvedPreference()
        let language = preference.resolvedLocalizationIdentifier()
        guard language != "en" else { return key }

        if let localized = CLIStringCatalog.shared.localized(key, languageIdentifier: language) {
            return localized
        }

        return self.dynamicTranslation(key)
    }

    private static func dynamicTranslation(_ text: String) -> String {
        if text.hasSuffix(" left") {
            let stem = String(text.dropLast(" left".count))
            return "剩余 \(stem)"
        }
        if text.hasSuffix(" used") {
            let stem = String(text.dropLast(" used".count))
            return "已用 \(stem)"
        }
        if text.hasSuffix("% in reserve") {
            let stem = String(text.dropLast("% in reserve".count))
            return "预留 \(stem)%（比预期少用）"
        }
        if text.hasSuffix("% in deficit") {
            let stem = String(text.dropLast("% in deficit".count))
            return "超前消耗 \(stem)%（比预期多用）"
        }
        if text.hasPrefix("Expected "), text.hasSuffix("% used") {
            let stem = String(text.dropFirst("Expected ".count).dropLast("% used".count))
            return "预期已用 \(stem)%"
        }
        if text.hasPrefix("Resets ") {
            let tail = String(text.dropFirst("Resets ".count))
            return "重置：\(self.translateTimePhrase(tail))"
        }
        if text.hasPrefix("Runs out in ") {
            let tail = String(text.dropFirst("Runs out in ".count))
            return "将在 \(self.translateTimePhrase(tail))后耗尽"
        }
        if text == "Runs out now" {
            return "现在耗尽"
        }
        if text.hasPrefix("Today: ") {
            return text.replacingOccurrences(of: "Today: ", with: "今日：")
        }
        if text.hasPrefix("Last 30 days: ") {
            return text.replacingOccurrences(of: "Last 30 days: ", with: "近 30 天：")
        }
        if text.hasPrefix("Error: ") {
            return text.replacingOccurrences(of: "Error: ", with: "错误：")
        }
        return text
    }

    private static func translateTimePhrase(_ text: String) -> String {
        var output = text
        output = output.replacingOccurrences(of: "just now", with: "刚刚")
        output = output.replacingOccurrences(of: "now", with: "现在")
        output = output.replacingOccurrences(of: "in ", with: "")
        output = output.replacingOccurrences(of: #"(\d+)d"#, with: "$1天", options: .regularExpression)
        output = output.replacingOccurrences(of: #"(\d+)h"#, with: "$1小时", options: .regularExpression)
        output = output.replacingOccurrences(of: #"(\d+)m"#, with: "$1分钟", options: .regularExpression)
        output = output.replacingOccurrences(of: " ago", with: "前")
        return output
    }
}

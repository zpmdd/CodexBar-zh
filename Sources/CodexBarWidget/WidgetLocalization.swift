import CodexBarCore
import Foundation
import SwiftUI

private struct WidgetXCStringCatalog: Decodable, Sendable {
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

private final class WidgetStringCatalog: @unchecked Sendable {
    static let shared = WidgetStringCatalog(bundle: .module)

    private let catalog: WidgetXCStringCatalog?
    private let bundle: Bundle

    init(bundle: Bundle) {
        self.bundle = bundle
        guard let url = bundle.url(forResource: "Localizable", withExtension: "xcstrings"),
              let data = try? Data(contentsOf: url)
        else {
            self.catalog = nil
            return
        }
        self.catalog = try? JSONDecoder().decode(WidgetXCStringCatalog.self, from: data)
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

enum WidgetL10n {
    static var locale: Locale {
        self.preference.effectiveLocale()
    }

    static func tr(_ key: String) -> String {
        let language = self.preference.resolvedLocalizationIdentifier()
        guard language != "en" else { return key }
        return WidgetStringCatalog.shared.localized(key, languageIdentifier: language) ?? key
    }

    static func text(_ key: String) -> Text {
        Text(verbatim: self.tr(key))
    }

    private static var preference: AppLanguagePreference {
        AppLanguageRuntime.resolvedPreference(userDefaults: AppGroupSupport.sharedDefaults() ?? .standard)
    }
}

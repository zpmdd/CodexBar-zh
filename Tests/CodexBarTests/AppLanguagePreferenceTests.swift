import CodexBarCore
import Foundation
import Testing

struct AppLanguagePreferenceTests {
    @Test
    func `environment override wins over stored preference`() throws {
        let suite = "AppLanguagePreferenceTests-env"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        defaults.set(AppLanguagePreference.english.rawValue, forKey: AppLanguagePreference.userDefaultsKey)

        let preference = AppLanguageRuntime.resolvedPreference(
            userDefaults: defaults,
            environment: ["CODEXBAR_LANG": "zh-Hans"])

        #expect(preference == .simplifiedChinese)
    }

    @Test
    func `system preference resolves Chinese only for Chinese preferred languages`() {
        #expect(
            AppLanguagePreference.system.resolvedLocalizationIdentifier(preferredLanguages: ["zh-Hans-CN"])
                == "zh-Hans")
        #expect(
            AppLanguagePreference.system.resolvedLocalizationIdentifier(preferredLanguages: ["en-US"])
                == "en")
    }
}

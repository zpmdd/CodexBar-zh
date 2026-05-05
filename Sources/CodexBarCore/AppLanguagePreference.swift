import Foundation

public enum AppLanguagePreference: String, CaseIterable, Codable, Identifiable, Sendable {
    case system
    case english
    case simplifiedChinese

    public static let userDefaultsKey = "appLanguagePreference"

    public var id: String {
        self.rawValue
    }

    public var localeIdentifier: String? {
        switch self {
        case .system:
            nil
        case .english:
            "en"
        case .simplifiedChinese:
            "zh-Hans"
        }
    }

    public func effectiveLocale(preferredLanguages: [String] = Locale.preferredLanguages) -> Locale {
        if let localeIdentifier {
            return Locale(identifier: localeIdentifier)
        }
        guard let preferred = preferredLanguages.first, !preferred.isEmpty else {
            return .autoupdatingCurrent
        }
        return Locale(identifier: preferred)
    }

    public func resolvedLocalizationIdentifier(preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        switch self {
        case .english:
            return "en"
        case .simplifiedChinese:
            return "zh-Hans"
        case .system:
            let preferred = preferredLanguages.first?.lowercased() ?? ""
            return preferred.hasPrefix("zh") ? "zh-Hans" : "en"
        }
    }

    public static func fromStoredRawValue(_ rawValue: String?) -> AppLanguagePreference {
        guard let rawValue, let preference = AppLanguagePreference(rawValue: rawValue) else {
            return .system
        }
        return preference
    }

    public static func fromEnvironmentValue(_ value: String?) -> AppLanguagePreference? {
        guard let value else { return nil }
        let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return nil }

        switch normalized {
        case "system", "default", "auto":
            return .system
        case "en", "en-us", "english":
            return .english
        case "zh", "zh-cn", "zh-hans", "zh_hans", "cn", "chinese", "simplifiedchinese", "simplified-chinese":
            return .simplifiedChinese
        default:
            return nil
        }
    }
}

public enum AppLanguageRuntime {
    @TaskLocal public static var scopedPreference: AppLanguagePreference?

    private static let lock = NSLock()
    private nonisolated(unsafe) static var inMemoryPreference: AppLanguagePreference?
    private static var isRunningTests: Bool {
        let environment = ProcessInfo.processInfo.environment
        let processName = ProcessInfo.processInfo.processName
        return environment["XCTestConfigurationFilePath"] != nil ||
            environment["XCTestBundlePath"] != nil ||
            processName == "swiftpm-testing-helper" ||
            processName.hasSuffix("PackageTests") ||
            processName.hasSuffix(".xctest")
    }

    public static func setInMemoryPreference(_ preference: AppLanguagePreference?) {
        self.lock.lock()
        self.inMemoryPreference = preference
        self.lock.unlock()
    }

    public static func withPreference<T>(
        _ preference: AppLanguagePreference?,
        operation: () throws -> T)
        rethrows -> T
    {
        try self.$scopedPreference.withValue(preference) {
            try operation()
        }
    }

    public static func resolvedPreference(
        userDefaults: UserDefaults = .standard,
        environment: [String: String] = ProcessInfo.processInfo.environment)
        -> AppLanguagePreference
    {
        if let override = AppLanguagePreference.fromEnvironmentValue(environment["CODEXBAR_LANG"]) {
            return override
        }

        if let scopedPreference {
            return scopedPreference
        }

        if self.isRunningTests {
            return .english
        }

        self.lock.lock()
        let inMemory = self.inMemoryPreference
        self.lock.unlock()
        if let inMemory {
            return inMemory
        }

        return AppLanguagePreference
            .fromStoredRawValue(userDefaults.string(forKey: AppLanguagePreference.userDefaultsKey))
    }
}

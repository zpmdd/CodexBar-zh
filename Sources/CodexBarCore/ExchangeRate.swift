import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct ExchangeRateSnapshot: Codable, Equatable, Sendable {
    public let baseCurrency: String
    public let quoteCurrency: String
    public let rate: Double
    public let rateDate: String
    public let fetchedAt: Date

    public init(
        baseCurrency: String,
        quoteCurrency: String,
        rate: Double,
        rateDate: String,
        fetchedAt: Date)
    {
        self.baseCurrency = baseCurrency
        self.quoteCurrency = quoteCurrency
        self.rate = rate
        self.rateDate = rateDate
        self.fetchedAt = fetchedAt
    }
}

public enum ExchangeRateError: LocalizedError, Sendable {
    case invalidHTTPStatus(Int)
    case invalidCurrencyPair(base: String, quote: String)
    case invalidRate(Double)

    public var errorDescription: String? {
        switch self {
        case let .invalidHTTPStatus(status):
            "Exchange rate request failed with HTTP \(status)."
        case let .invalidCurrencyPair(base, quote):
            "Expected USD/CNY exchange rate, got \(base)/\(quote)."
        case let .invalidRate(rate):
            "Exchange rate response contained invalid rate \(rate)."
        }
    }
}

public enum ExchangeRateClient {
    public static let frankfurterUSDCNYURL = URL(string: "https://api.frankfurter.dev/v2/rate/USD/CNY")!

    private struct FrankfurterRateResponse: Decodable {
        let date: String
        let base: String
        let quote: String
        let rate: Double
    }

    public static func fetchUSDCNYRateData() async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: self.frankfurterUSDCNYURL)
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw ExchangeRateError.invalidHTTPStatus(http.statusCode)
        }
        return data
    }

    public static func parseUSDCNYRate(from data: Data, fetchedAt: Date) throws -> ExchangeRateSnapshot {
        let decoded = try JSONDecoder().decode(FrankfurterRateResponse.self, from: data)
        let base = decoded.base.uppercased()
        let quote = decoded.quote.uppercased()
        guard base == "USD", quote == "CNY" else {
            throw ExchangeRateError.invalidCurrencyPair(base: decoded.base, quote: decoded.quote)
        }
        guard decoded.rate > 0 else {
            throw ExchangeRateError.invalidRate(decoded.rate)
        }
        return ExchangeRateSnapshot(
            baseCurrency: base,
            quoteCurrency: quote,
            rate: decoded.rate,
            rateDate: decoded.date,
            fetchedAt: fetchedAt)
    }
}

public final class USDToCNYExchangeRateStore: @unchecked Sendable {
    public typealias DataLoader = @Sendable () async throws -> Data

    public static let refreshInterval: TimeInterval = 6 * 60 * 60

    private let lock = NSLock()
    private let userDefaults: UserDefaults
    private let cacheKey: String
    private let dataLoader: DataLoader

    public init(
        userDefaults: UserDefaults = .standard,
        cacheKey: String = "CodexBar.exchangeRate.usdCNY.snapshot",
        dataLoader: @escaping DataLoader = ExchangeRateClient.fetchUSDCNYRateData)
    {
        self.userDefaults = userDefaults
        self.cacheKey = cacheKey
        self.dataLoader = dataLoader
    }

    public func cachedSnapshot() -> ExchangeRateSnapshot? {
        let data = self.lock.withLock {
            self.userDefaults.data(forKey: self.cacheKey)
        }
        guard let data else { return nil }
        return try? JSONDecoder().decode(ExchangeRateSnapshot.self, from: data)
    }

    public func store(_ snapshot: ExchangeRateSnapshot) {
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        self.lock.withLock {
            self.userDefaults.set(data, forKey: self.cacheKey)
        }
    }

    public func refreshIfNeeded(
        now: Date = .init(),
        maxAge: TimeInterval = USDToCNYExchangeRateStore.refreshInterval) async -> ExchangeRateSnapshot?
    {
        let cached = self.cachedSnapshot()
        if let cached, now.timeIntervalSince(cached.fetchedAt) < maxAge {
            return cached
        }

        do {
            let data = try await self.dataLoader()
            let snapshot = try ExchangeRateClient.parseUSDCNYRate(from: data, fetchedAt: now)
            self.store(snapshot)
            return snapshot
        } catch {
            return cached
        }
    }
}

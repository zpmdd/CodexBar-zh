import CodexBarCore
import Foundation
import Testing

struct ExchangeRateTests {
    @Test
    func `parses Frankfurter USD CNY response`() throws {
        let data = Data(#"{"date":"2026-05-04","base":"USD","quote":"CNY","rate":6.8311}"#.utf8)
        let fetchedAt = Date(timeIntervalSince1970: 1_777_666_666)

        let snapshot = try ExchangeRateClient.parseUSDCNYRate(from: data, fetchedAt: fetchedAt)

        #expect(snapshot.baseCurrency == "USD")
        #expect(snapshot.quoteCurrency == "CNY")
        #expect(snapshot.rate == 6.8311)
        #expect(snapshot.rateDate == "2026-05-04")
        #expect(snapshot.fetchedAt == fetchedAt)
    }

    @Test
    func `uses cached exchange rate when refresh fails`() async throws {
        let defaults = try Self.makeDefaults()
        let cached = ExchangeRateSnapshot(
            baseCurrency: "USD",
            quoteCurrency: "CNY",
            rate: 7.1,
            rateDate: "2026-05-03",
            fetchedAt: Date(timeIntervalSince1970: 1_777_000_000))
        let store = USDToCNYExchangeRateStore(userDefaults: defaults) {
            throw URLError(.notConnectedToInternet)
        }
        store.store(cached)

        let snapshot = await store.refreshIfNeeded(
            now: cached.fetchedAt.addingTimeInterval(7 * 60 * 60))

        #expect(snapshot == cached)
    }

    @Test
    func `returns nil when refresh fails without cached exchange rate`() async throws {
        let defaults = try Self.makeDefaults()
        let store = USDToCNYExchangeRateStore(userDefaults: defaults) {
            throw URLError(.notConnectedToInternet)
        }

        let snapshot = await store.refreshIfNeeded(
            now: Date(timeIntervalSince1970: 1_777_000_000))

        #expect(snapshot == nil)
    }

    private static func makeDefaults() throws -> UserDefaults {
        let suite = "ExchangeRateTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }
}

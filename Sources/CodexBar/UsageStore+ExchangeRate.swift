import CodexBarCore
import Foundation

extension UsageStore {
    func scheduleExchangeRateRefreshIfNeededForCostDisplay(force: Bool = false) {
        guard self.settings.costUsageEnabled else { return }
        guard self.hasRenderableUSDCost else { return }
        let now = Date()
        if !force,
           let current = self.usdCNYExchangeRate,
           now.timeIntervalSince(current.fetchedAt) < USDToCNYExchangeRateStore.refreshInterval
        {
            return
        }
        if !force, self.exchangeRateRefreshTask != nil { return }
        if !force,
           let lastAttempt = self.lastExchangeRateRefreshAttemptAt,
           now.timeIntervalSince(lastAttempt) < 10 * 60
        {
            return
        }

        self.exchangeRateRefreshTask?.cancel()
        self.lastExchangeRateRefreshAttemptAt = now
        let store = self.exchangeRateStore
        self.exchangeRateRefreshTask = Task(priority: .utility) { [weak self] in
            let snapshot = await store.refreshIfNeeded(now: now)
            await MainActor.run {
                guard let self else { return }
                self.usdCNYExchangeRate = snapshot
                self.exchangeRateRefreshTask = nil
            }
        }
    }

    private var hasRenderableUSDCost: Bool {
        self.tokenSnapshots.values.contains { snapshot in
            if snapshot.sessionCostUSD != nil || snapshot.last30DaysCostUSD != nil { return true }
            return snapshot.daily.contains { entry in
                if entry.costUSD != nil { return true }
                return entry.modelBreakdowns?.contains { $0.costUSD != nil } ?? false
            }
        }
    }
}

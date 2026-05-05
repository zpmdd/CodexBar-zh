import CodexBarCore
import Foundation
import Testing
@testable import CodexBar

struct UsageStorePlanUtilizationDerivedChartTests {
    @MainActor
    @Test
    func `chart uses requested native series without cross series selection`() {
        let firstBoundary = Date(timeIntervalSince1970: 1_710_000_000)
        let secondBoundary = firstBoundary.addingTimeInterval(7 * 24 * 60 * 60)
        let histories = [
            planSeries(name: .session, windowMinutes: 300, entries: [
                planEntry(at: firstBoundary.addingTimeInterval(-30 * 60), usedPercent: 20, resetsAt: firstBoundary),
            ]),
            planSeries(name: .weekly, windowMinutes: 10080, entries: [
                planEntry(at: firstBoundary.addingTimeInterval(-30 * 60), usedPercent: 62, resetsAt: firstBoundary),
                planEntry(at: secondBoundary.addingTimeInterval(-30 * 60), usedPercent: 48, resetsAt: secondBoundary),
            ]),
        ]

        let model = PlanUtilizationHistoryChartMenuView._modelSnapshotForTesting(
            selectedSeriesRawValue: "weekly:10080",
            histories: histories,
            provider: .codex,
            referenceDate: secondBoundary)

        #expect(model.selectedSeries == "weekly:10080")
        #expect(model.usedPercents == [62, 48])
    }

    @MainActor
    @Test
    func `chart exposes claude opus as separate native tab`() {
        let boundary = Date(timeIntervalSince1970: 1_710_000_000)
        let histories = [
            planSeries(name: .session, windowMinutes: 300, entries: [
                planEntry(at: boundary.addingTimeInterval(-30 * 60), usedPercent: 10, resetsAt: boundary),
            ]),
            planSeries(name: .weekly, windowMinutes: 10080, entries: [
                planEntry(at: boundary.addingTimeInterval(-30 * 60), usedPercent: 20, resetsAt: boundary),
            ]),
            planSeries(name: .opus, windowMinutes: 10080, entries: [
                planEntry(at: boundary.addingTimeInterval(-30 * 60), usedPercent: 30, resetsAt: boundary),
            ]),
        ]

        let model = PlanUtilizationHistoryChartMenuView._modelSnapshotForTesting(
            histories: histories,
            provider: .claude,
            referenceDate: boundary)

        #expect(model.visibleSeries == ["session:300", "weekly:10080", "opus:10080"])
    }

    @MainActor
    @Test
    func `chart detail line localizes selected usage point`() throws {
        var components = DateComponents()
        components.calendar = Calendar.current
        components.timeZone = TimeZone.current
        components.year = 2026
        components.month = 5
        components.day = 5
        components.hour = 11
        components.minute = 47
        let boundary = try #require(components.date)
        let histories = [
            planSeries(name: .session, windowMinutes: 300, entries: [
                planEntry(at: boundary.addingTimeInterval(-30 * 60), usedPercent: 8, resetsAt: boundary),
            ]),
        ]

        let line = AppLanguageRuntime.withPreference(.simplifiedChinese) {
            PlanUtilizationHistoryChartMenuView._detailLineForTesting(
                selectedSeriesRawValue: "session:300",
                histories: histories,
                provider: .codex,
                referenceDate: boundary)
        }

        #expect(AppLanguageRuntime.withPreference(.simplifiedChinese) {
            CodexBarL10n.tr(line)
        } == "5月5日 11:47：已用 8%")
    }
}

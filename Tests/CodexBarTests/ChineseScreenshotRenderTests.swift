import AppKit
import CodexBarCore
import SwiftUI
import Testing
@testable import CodexBar

@MainActor
struct ChineseScreenshotRenderTests {
    @Test
    func `write Chinese README screenshots when requested`() throws {
        guard ProcessInfo.processInfo.environment["CODEXBAR_WRITE_SCREENSHOTS"] == "1" else {
            return
        }

        let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent("docs/screenshots", isDirectory: true)
        try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)

        let context = Self.makeContext()
        try Self.render(
            ChineseMenuPreview(model: Self.menuModel(now: context.now), breakdown: Self.breakdown()),
            size: CGSize(width: 930, height: 560),
            to: outputDir.appendingPathComponent("zh-menu.png"))

        try Self.render(
            PreferencesScreenshot(tab: .display, context: context),
            size: CGSize(width: 620, height: 720),
            to: outputDir.appendingPathComponent("zh-display.png"))

        try Self.render(
            PreferencesScreenshot(tab: .advanced, context: context),
            size: CGSize(width: 620, height: 720),
            to: outputDir.appendingPathComponent("zh-advanced.png"))

        try Self.render(
            PreferencesScreenshot(tab: .about, context: context),
            size: CGSize(width: 620, height: 720),
            to: outputDir.appendingPathComponent("zh-about.png"))
    }

    struct ScreenshotContext {
        let settings: SettingsStore
        let store: UsageStore
        let now: Date
    }

    private static func makeContext() -> ScreenshotContext {
        let suite = "ChineseScreenshotRenderTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let settings = SettingsStore(
            userDefaults: defaults,
            configStore: testConfigStore(suiteName: suite),
            zaiTokenStore: NoopZaiTokenStore(),
            syntheticTokenStore: NoopSyntheticTokenStore(),
            codexCookieStore: InMemoryCookieHeaderStore(),
            claudeCookieStore: InMemoryCookieHeaderStore(),
            cursorCookieStore: InMemoryCookieHeaderStore(),
            opencodeCookieStore: InMemoryCookieHeaderStore(),
            factoryCookieStore: InMemoryCookieHeaderStore(),
            minimaxCookieStore: InMemoryMiniMaxCookieStore(),
            minimaxAPITokenStore: InMemoryMiniMaxAPITokenStore(),
            kimiTokenStore: InMemoryKimiTokenStore(),
            kimiK2TokenStore: InMemoryKimiK2TokenStore(),
            augmentCookieStore: InMemoryCookieHeaderStore(),
            ampCookieStore: InMemoryCookieHeaderStore(),
            copilotTokenStore: InMemoryCopilotTokenStore(),
            tokenAccountStore: InMemoryTokenAccountStore())
        settings.hidePersonalInfo = true
        settings.mergeIcons = true
        settings.switcherShowsIcons = true
        settings.menuBarShowsBrandIconWithPercent = true
        settings.showOptionalCreditsAndExtraUsage = true
        settings.showAllTokenAccountsInMenu = true

        let store = UsageStore(
            fetcher: UsageFetcher(environment: [:]),
            browserDetection: BrowserDetection(cacheTTL: 0),
            settings: settings)
        return ScreenshotContext(settings: settings, store: store, now: Date(timeIntervalSince1970: 1_775_400_000))
    }

    private static func menuModel(now: Date) -> UsageMenuCardView.Model {
        let session = UsageMenuCardView.Model.Metric(
            id: "primary",
            title: "Session",
            percent: 92,
            percentStyle: .left,
            resetText: "Resets in 1h 7m",
            detailText: nil,
            detailLeftText: nil,
            detailRightText: nil,
            pacePercent: nil,
            paceOnTop: true)
        let weekly = UsageMenuCardView.Model.Metric(
            id: "secondary",
            title: "Weekly",
            percent: 95,
            percentStyle: .left,
            resetText: "Resets in 4d 3h",
            detailText: nil,
            detailLeftText: "36% in reserve",
            detailRightText: "Lasts until reset",
            pacePercent: 36,
            paceOnTop: true)
        return UsageMenuCardView.Model(
            provider: .codex,
            providerName: "Codex",
            email: PersonalInfoRedactor.emailPlaceholder,
            subtitleText: UsageFormatter.updatedString(from: now, now: now),
            subtitleStyle: .info,
            planText: "Pro",
            metrics: [session, weekly],
            usageNotes: [],
            creditsText: "0 left",
            creditsRemaining: 0,
            creditsHintText: nil,
            creditsHintCopyText: nil,
            providerCost: nil,
            tokenUsage: UsageMenuCardView.Model.TokenUsageSection(
                sessionLine: "Today: ¥424.91 · $62.22 · 78M tokens",
                monthLine: "Last 30 days: ¥10,786.12 · $1,579.35 · 3.3B tokens",
                hintLine: nil,
                errorLine: nil,
                errorCopyText: nil),
            placeholder: nil,
            progressColor: Color(red: 0.20, green: 0.52, blue: 0.96))
    }

    private static func breakdown() -> [OpenAIDashboardDailyBreakdown] {
        [
            OpenAIDashboardDailyBreakdown(
                day: "2026-04-06",
                services: [
                    OpenAIDashboardServiceUsage(service: "Desktop App", creditsUsed: 0.12),
                    OpenAIDashboardServiceUsage(service: "Jetbrains", creditsUsed: 0.08),
                ],
                totalCreditsUsed: 0.2),
            OpenAIDashboardDailyBreakdown(
                day: "2026-05-02",
                services: [
                    OpenAIDashboardServiceUsage(service: "Desktop App", creditsUsed: 29.2),
                    OpenAIDashboardServiceUsage(service: "Jetbrains", creditsUsed: 7.64),
                ],
                totalCreditsUsed: 36.84),
            OpenAIDashboardDailyBreakdown(
                day: "2026-05-03",
                services: [
                    OpenAIDashboardServiceUsage(service: "Desktop App", creditsUsed: 3.1),
                    OpenAIDashboardServiceUsage(service: "Jetbrains", creditsUsed: 1.1),
                ],
                totalCreditsUsed: 4.2),
        ]
    }

    private static func render<Content: View>(_ view: Content, size: CGSize, to url: URL) throws {
        let host = NSHostingView(rootView: view
            .environment(\.colorScheme, .dark)
            .environment(\.locale, Locale(identifier: "zh-Hans")))
        host.frame = NSRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        window.contentView = host
        window.orderFrontRegardless()
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.4))

        guard let rep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else {
            throw CocoaError(.fileWriteUnknown)
        }
        host.cacheDisplay(in: host.bounds, to: rep)
        guard let data = rep.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        try data.write(to: url, options: .atomic)
        window.orderOut(nil)
    }
}

@MainActor
private struct ChineseMenuPreview: View {
    let model: UsageMenuCardView.Model
    let breakdown: [OpenAIDashboardDailyBreakdown]

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 0) {
                UsageMenuCardView(model: self.model, width: 410)
                Divider().padding(.horizontal, 16)
                self.actionRow(systemImage: "person.crop.circle", title: "System Account")
                self.actionRow(systemImage: "chart.bar", title: "Usage Dashboard")
                self.actionRow(systemImage: "waveform.path.ecg", title: "Status Page")
                LText("Partial System Degradation — Updated 5:59")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                Divider().padding(.horizontal, 16).padding(.top, 8)
                self.actionRow(systemImage: "arrow.clockwise", title: "Refresh")
                self.actionRow(systemImage: "gearshape", title: "Settings...")
                self.actionRow(systemImage: "info.circle", title: "About CodexBar")
            }
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.92)))

            UsageBreakdownChartMenuView(breakdown: self.breakdown, width: 420)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(nsColor: .windowBackgroundColor).opacity(0.92)))
        }
        .padding(18)
        .background(Color(nsColor: .underPageBackgroundColor))
    }

    private func actionRow(systemImage: String, title: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .frame(width: 18)
            LText(title)
            Spacer()
        }
        .font(.body)
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }
}

@MainActor
private struct PreferencesScreenshot: View {
    let tab: PreferencesTab
    let context: ChineseScreenshotRenderTests.ScreenshotContext

    var body: some View {
        VStack(spacing: 16) {
            ScreenshotTabBar(selected: self.tab)
            Group {
                switch self.tab {
                case .display:
                    DisplayPane(settings: self.context.settings, store: self.context.store)
                case .advanced:
                    AdvancedPane(settings: self.context.settings)
                case .about:
                    AboutPane(updater: DisabledUpdaterController())
                case .general:
                    GeneralPane(settings: self.context.settings, store: self.context.store)
                case .providers:
                    DisplayPane(settings: self.context.settings, store: self.context.store)
                case .debug:
                    AdvancedPane(settings: self.context.settings)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color(nsColor: .separatorColor), lineWidth: 1)))
        }
        .padding(28)
        .background(Color(nsColor: .underPageBackgroundColor))
    }
}

private struct ScreenshotTabBar: View {
    let selected: PreferencesTab

    private let tabs: [(PreferencesTab, String)] = [
        (.general, "gearshape"),
        (.providers, "square.grid.2x2"),
        (.display, "eye"),
        (.advanced, "slider.horizontal.3"),
        (.about, "info.circle"),
    ]

    var body: some View {
        HStack(spacing: 18) {
            ForEach(self.tabs, id: \.0) { tab, systemImage in
                VStack(spacing: 4) {
                    Image(systemName: systemImage)
                        .font(.system(size: 25, weight: .semibold))
                    LText(tab.title)
                        .font(.callout)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(tab == self.selected ? Color.accentColor : Color.secondary)
                .frame(width: 76, height: 58)
                .background {
                    if tab == self.selected {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.accentColor.opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.accentColor.opacity(0.35), lineWidth: 1))
                    }
                }
            }
        }
    }
}

import Testing
@testable import CodexBar

struct CodexBarLocalizationTests {
    @Test
    func `translates core menu and settings labels`() {
        #expect(CodexBarL10n.tr("Settings...") == "设置...")
        #expect(CodexBarL10n.tr("Usage Dashboard") == "用量看板")
        #expect(CodexBarL10n.tr("Show cost summary") == "显示费用摘要")
        #expect(CodexBarL10n.tr("Merge Icons") == "合并图标")
    }

    @Test
    func `translates display pane help text`() {
        #expect(
            CodexBarL10n.tr("Show provider icons in the switcher (otherwise show a weekly progress line).") ==
                "在切换器中显示服务图标，否则显示每周进度线。")
        #expect(
            CodexBarL10n.tr("Menu bar auto-shows the provider closest to its rate limit.") ==
                "菜单栏会自动显示最接近限额的服务。")
        #expect(
            CodexBarL10n.tr("Replace critter bars with provider branding icons and a percentage.") ==
                "用服务品牌图标和百分比替代用量条。")
        #expect(
            CodexBarL10n.tr("Progress bars fill as you consume quota (instead of showing remaining).") ==
                "进度条随配额消耗逐步填充，而不是显示剩余量。")
        #expect(
            CodexBarL10n.tr("Stack token accounts in the menu (otherwise show an account switcher bar).") ==
                "在菜单中堆叠显示 token 账户，否则显示账户切换栏。")
    }

    @Test
    func `translates dynamic usage and account lines`() {
        #expect(CodexBarL10n.tr("Account: user@example.com") == "账户：user@example.com")
        #expect(CodexBarL10n.tr("Plan: Plus") == "套餐：Plus")
        #expect(CodexBarL10n.tr("73% left") == "剩余 73%")
        #expect(CodexBarL10n.tr("18% used") == "已用 18%")
        #expect(CodexBarL10n.tr("33% in reserve") == "预留 33%（比预期少用）")
        #expect(CodexBarL10n.tr("7% in deficit") == "超前消耗 7%（比预期多用）")
        #expect(CodexBarL10n.tr("Lasts until reset") == "可持续到重置")
        #expect(CodexBarL10n.tr("Runs out in 3d") == "将在 3天后耗尽")
        #expect(CodexBarL10n.tr("≈ 70% run-out risk") == "约 70% 耗尽风险")
        #expect(CodexBarL10n.tr("Resets in 2h 5m") == "重置：2小时 5分钟")
    }

    @Test
    func `translates dynamic status lines`() {
        #expect(CodexBarL10n.tr("Codex: unsupported") == "Codex：不支持")
        #expect(CodexBarL10n.tr("Codex: no data yet") == "Codex：暂无数据")
        #expect(CodexBarL10n.tr("Version 0.23 (58)") == "版本 0.23 (58)")
        #expect(
            CodexBarL10n.tr("Partial System Degradation — Updated 5:59") ==
                "官方部分服务不稳定 - 更新于 5:59")
        #expect(CodexBarL10n.tr("Degraded performance") == "官方服务性能下降")
        #expect(CodexBarL10n.tr("Major System Outage") == "官方服务大范围异常")
    }

    @Test
    func `translates main menu chart and action labels`() {
        #expect(CodexBarL10n.tr("Hover a bar for details") == "悬停柱形查看详情")
        #expect(CodexBarL10n.tr("Desktop App") == "桌面应用")
        #expect(CodexBarL10n.tr("Jetbrains") == "JetBrains")
        #expect(CodexBarL10n.tr("System Account") == "系统账户")
        #expect(CodexBarL10n.tr("Record Shortcut") == "设置快捷键")
        #expect(CodexBarL10n.tr("record_shortcut") == "设置快捷键")
        #expect(CodexBarL10n.tr("Email") == "邮件")
    }
}

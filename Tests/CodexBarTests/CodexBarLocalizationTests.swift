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
    func `translates dynamic usage and account lines`() {
        #expect(CodexBarL10n.tr("Account: user@example.com") == "账户：user@example.com")
        #expect(CodexBarL10n.tr("Plan: Plus") == "套餐：Plus")
        #expect(CodexBarL10n.tr("73% left") == "剩余 73%")
        #expect(CodexBarL10n.tr("18% used") == "已用 18%")
        #expect(CodexBarL10n.tr("Resets in 2h 5m") == "重置：2小时 5分钟")
    }

    @Test
    func `translates dynamic status lines`() {
        #expect(CodexBarL10n.tr("Codex: unsupported") == "Codex：不支持")
        #expect(CodexBarL10n.tr("Codex: no data yet") == "Codex：暂无数据")
        #expect(CodexBarL10n.tr("Version 0.23 (58)") == "版本 0.23 (58)")
    }
}

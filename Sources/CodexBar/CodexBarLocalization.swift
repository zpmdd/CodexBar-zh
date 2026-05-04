import Foundation
import SwiftUI

enum CodexBarL10n {
    static func tr(_ rawText: String) -> String {
        guard self.isChineseEnabled else { return rawText }

        if let exact = self.exactTranslations[rawText] {
            return exact
        }

        return self.dynamicTranslation(rawText)
    }

    private static var isChineseEnabled: Bool {
        let value = ProcessInfo.processInfo.environment["CODEXBAR_LANG"]?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        return value != "en" && value != "english"
    }

    private static func dynamicTranslation(_ text: String) -> String {
        if text.hasPrefix("Account: ") {
            return text.replacingOccurrences(of: "Account: ", with: "账户：")
        }
        if text.hasPrefix("Plan: ") {
            return text.replacingOccurrences(of: "Plan: ", with: "套餐：")
        }
        if text.hasPrefix("Activity: ") {
            return text.replacingOccurrences(of: "Activity: ", with: "活动：")
        }
        if text.hasPrefix("Quota: ") {
            return text.replacingOccurrences(of: "Quota: ", with: "配额：")
        }
        if text.hasPrefix("Credits: ") {
            return text.replacingOccurrences(of: "Credits: ", with: "积分：")
        }
        if text.hasPrefix("Last spend: ") {
            return text.replacingOccurrences(of: "Last spend: ", with: "最近花费：")
        }
        if text.hasPrefix("Last ") && text.hasSuffix(" fetch failed:") {
            let provider = text
                .replacingOccurrences(of: "Last ", with: "")
                .replacingOccurrences(of: " fetch failed:", with: "")
            return "最近一次 \(provider) 拉取失败："
        }
        if text.hasPrefix("Write logs to ") && text.hasSuffix(" for debugging.") {
            let path = text
                .replacingOccurrences(of: "Write logs to ", with: "")
                .replacingOccurrences(of: " for debugging.", with: "")
            return "将日志写入 \(path) 以便调试。"
        }
        if text.hasPrefix("CodexBar found multiple workspaces for ") &&
            text.hasSuffix(". Choose the one to add.")
        {
            let email = text
                .replacingOccurrences(of: "CodexBar found multiple workspaces for ", with: "")
                .replacingOccurrences(of: ". Choose the one to add.", with: "")
            return "CodexBar 为 \(email) 找到多个工作区。请选择要添加的工作区。"
        }
        if text.hasPrefix("Remove ") && text.hasSuffix(" from CodexBar? Its managed Codex home will be deleted.") {
            let account = text
                .replacingOccurrences(of: "Remove ", with: "")
                .replacingOccurrences(of: " from CodexBar? Its managed Codex home will be deleted.", with: "")
            return "要从 CodexBar 移除 \(account) 吗？其托管的 Codex home 将被删除。"
        }
        if text.hasPrefix("A device code has been copied to your clipboard: ") {
            let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
            guard let first = lines.first else { return text }
            let code = first.replacingOccurrences(
                of: "A device code has been copied to your clipboard: ",
                with: "")
            let verifyLine = lines.last.map(String.init) ?? ""
            let uri = verifyLine.replacingOccurrences(of: "Please verify it at: ", with: "")
            return "设备码已复制到剪贴板：\(code)\n\n请前往此地址验证：\(uri)"
        }
        if text.hasPrefix("Disabled — ") {
            let tail = String(text.dropFirst("Disabled — ".count))
            return "已禁用 - \(self.tr(tail))"
        }
        if text.hasPrefix("Updated ") {
            let tail = String(text.dropFirst("Updated ".count))
            return "更新于 \(self.translateTimePhrase(tail))"
        }
        if text.hasPrefix("Resets ") {
            let tail = String(text.dropFirst("Resets ".count))
            return "重置：\(self.translateTimePhrase(tail))"
        }
        if text.hasPrefix("Regenerates ") {
            let tail = String(text.dropFirst("Regenerates ".count))
            return "恢复：\(self.translateTimePhrase(tail))"
        }
        if text.hasPrefix("Today: ") {
            return text.replacingOccurrences(of: "Today: ", with: "今日：")
                .replacingOccurrences(of: " tokens", with: " tokens")
        }
        if text.hasPrefix("Last 30 days: ") {
            return text.replacingOccurrences(of: "Last 30 days: ", with: "近 30 天：")
                .replacingOccurrences(of: " tokens", with: " tokens")
        }
        if text.hasPrefix("This month: ") {
            return text.replacingOccurrences(of: "This month: ", with: "本月：")
        }
        if text.hasPrefix("Total (30d): ") {
            return text.replacingOccurrences(of: "Total (30d): ", with: "近 30 天合计：")
                .replacingOccurrences(of: " credits", with: " 积分")
        }
        if text.hasPrefix("Version ") {
            return text.replacingOccurrences(of: "Version ", with: "版本 ")
        }
        if text.hasPrefix("Built ") {
            return text.replacingOccurrences(of: "Built ", with: "构建于 ")
        }
        if text.hasPrefix("Primary (") && text.hasSuffix(")") {
            return text
                .replacingOccurrences(of: "Primary (", with: "主要（")
                .replacingOccurrences(of: ")", with: "）")
        }
        if text.hasPrefix("Secondary (") && text.hasSuffix(")") {
            return text
                .replacingOccurrences(of: "Secondary (", with: "次要（")
                .replacingOccurrences(of: ")", with: "）")
        }
        if text.hasPrefix("Tertiary (") && text.hasSuffix(")") {
            return text
                .replacingOccurrences(of: "Tertiary (", with: "第三项（")
                .replacingOccurrences(of: ")", with: "）")
        }
        if text.hasPrefix("Average (") && text.hasSuffix(")") {
            return text
                .replacingOccurrences(of: "Average (", with: "平均（")
                .replacingOccurrences(of: ")", with: "）")
        }
        if text.hasPrefix("Window: ") {
            return text.replacingOccurrences(of: "Window: ", with: "窗口：")
        }
        if text.hasPrefix("Resets: ") {
            let tail = String(text.dropFirst("Resets: ".count))
            return "重置：\(self.translateTimePhrase(tail))"
        }
        if text.hasPrefix("Installed: ") {
            return text.replacingOccurrences(of: "Installed: ", with: "已安装：")
        }
        if text.hasPrefix("No write access: ") {
            return text.replacingOccurrences(of: "No write access: ", with: "无写入权限：")
        }
        if text.hasPrefix("Exists: ") {
            return text.replacingOccurrences(of: "Exists: ", with: "已存在：")
        }
        if text.hasPrefix("Failed: ") {
            return text.replacingOccurrences(of: "Failed: ", with: "失败：")
        }
        if text.hasSuffix(": unsupported") {
            return text.replacingOccurrences(of: ": unsupported", with: "：不支持")
        }
        if text.contains(": fetching…") {
            return text.replacingOccurrences(of: ": fetching…", with: "：正在获取...")
        }
        if text.hasSuffix(": no data yet") {
            return text.replacingOccurrences(of: ": no data yet", with: "：暂无数据")
        }
        if text.contains(": last attempt ") {
            return text.replacingOccurrences(of: ": last attempt ", with: "：上次尝试 ")
        }
        if text.contains(" · 30d ") {
            return text.replacingOccurrences(of: " · 30d ", with: " · 近 30 天 ")
        }
        if text.hasSuffix(" login successful") {
            return text.replacingOccurrences(of: " login successful", with: " 登录成功")
        }
        if text.hasSuffix(" left") {
            let stem = String(text.dropLast(" left".count))
            return "剩余 \(stem)"
        }
        if text.hasSuffix(" used") {
            let stem = String(text.dropLast(" used".count))
            return "已用 \(stem)"
        }
        if text.hasSuffix(" remaining") {
            let stem = String(text.dropLast(" remaining".count))
            return "剩余 \(stem)"
        }
        if text.hasSuffix(" used after next regen") {
            let stem = String(text.dropLast(" used after next regen".count))
            return "下次恢复后已用 \(stem)"
        }
        if text.hasSuffix(" after next regen") {
            let stem = String(text.dropLast(" after next regen".count))
            return "下次恢复后 \(stem)"
        }
        if text.hasPrefix("Full in ~") {
            return text.replacingOccurrences(of: "Full in ~", with: "约 ")
                .replacingOccurrences(of: " regen", with: " 次恢复后满额")
                .replacingOccurrences(of: " regens", with: " 次恢复后满额")
        }
        if text.hasPrefix("Choose up to ") && text.hasSuffix(" providers") {
            let number = text
                .replacingOccurrences(of: "Choose up to ", with: "")
                .replacingOccurrences(of: " providers", with: "")
            return "最多选择 \(number) 个服务"
        }

        return text
    }

    private static func translateTimePhrase(_ text: String) -> String {
        var output = text
        output = output.replacingOccurrences(of: "just now", with: "刚刚")
        output = output.replacingOccurrences(of: "now", with: "现在")
        output = output.replacingOccurrences(of: "tomorrow, ", with: "明天 ")
        output = output.replacingOccurrences(of: "in ", with: "")
        output = output.replacingOccurrences(of: #"(\d+)d"#, with: "$1天", options: .regularExpression)
        output = output.replacingOccurrences(of: #"(\d+)h"#, with: "$1小时", options: .regularExpression)
        output = output.replacingOccurrences(of: #"(\d+)m"#, with: "$1分钟", options: .regularExpression)
        output = output.replacingOccurrences(of: " ago", with: "前")
        return output
    }

    private static let exactTranslations: [String: String] = [
        "About": "关于",
        "About CodexBar": "关于 CodexBar",
        "Account": "账户",
        "Accounts": "账户",
        "Account Added": "账户已添加",
        "Active": "当前",
        "Add": "添加",
        "Add Account": "添加账户",
        "Add Account...": "添加账户...",
        "Adding Account…": "正在添加账户...",
        "Add accounts via GitHub OAuth Device Flow.": "通过 GitHub OAuth 设备流程添加账户。",
        "Add Workspace": "添加工作区",
        "Advanced": "高级",
        "Animation pattern": "动画样式",
        "API key limit": "API Key 限额",
        "API key limit unavailable right now": "当前无法获取 API Key 限额",
        "Auto": "自动",
        "Auto-refresh is off; use the menu's Refresh command.": "自动刷新已关闭；请使用菜单里的“刷新”命令。",
        "Auto-refresh: hourly · Timeout: 10m": "自动刷新：每小时 · 超时：10 分钟",
        "Automation": "自动化",
        "Balance": "余额",
        "Beta": "Beta 版",
        "Blink now": "立即闪烁",
        "Built": "构建于",
        "Cancel": "取消",
        "Check for updates automatically": "自动检查更新",
        "Check for Updates…": "检查更新...",
        "Check provider status": "检查服务状态",
        "Choose Codex workspace": "选择 Codex 工作区",
        "Choose which Codex account CodexBar should follow.": "选择 CodexBar 要跟随的 Codex 账户。",
        "Choose what to show in the menu bar (Pace shows usage vs. expected).": "选择菜单栏显示内容；“节奏”会显示实际用量与预期用量的对比。",
        "Clear cost cache": "清除费用缓存",
        "Clear cost error": "清除费用错误",
        "Clear menu error": "清除菜单错误",
        "Cleared.": "已清除。",
        "CLI paths": "CLI 路径",
        "CLI sessions": "CLI 会话",
        "Code review": "代码审查",
        "Codex account login already running": "Codex 账户登录已在进行",
        "Codex login completed, but no account email was available. Try again after confirming the account is fully signed in.": "Codex 登录已完成，但没有获取到账户邮箱。请确认账户已完整登录后重试。",
        "CodexBar could not read managed account storage. Recover the store before adding another account.": "CodexBar 无法读取托管账户存储。请先恢复该存储，再添加其他账户。",
        "CodexBar found multiple workspaces, but no workspace was selected.": "CodexBar 发现多个工作区，但未选择任何工作区。",
        "Configure…": "配置...",
        "Controls how much detail is logged.": "控制日志记录的详细程度。",
        "Copied": "已复制",
        "Copy": "复制",
        "Copy error": "复制错误",
        "Could not add Codex account": "无法添加 Codex 账户",
        "Could not open Terminal for Gemini": "无法为 Gemini 打开终端",
        "Could not start claude /login": "无法启动 claude /login",
        "Cost": "费用",
        "Credits": "积分",
        "Credits remaining": "剩余积分",
        "Current": "当前",
        "Debug": "调试",
        "Display": "显示",
        "Display mode": "显示模式",
        "Disable OpenAI dashboard cookie usage.": "禁用 OpenAI 看板 cookie 用法。",
        "Drag to reorder": "拖动排序",
        "Effective PATH": "生效的 PATH",
        "Enable Merge Icons to configure Overview tab providers.": "启用“合并图标”后可配置概览页服务。",
        "Enable file logging": "启用文件日志",
        "Enabled": "已启用",
        "Error simulation": "错误模拟",
        "Expose troubleshooting tools in the Debug tab.": "在调试页显示故障排查工具。",
        "Extra usage": "额外用量",
        "Extra usage spent": "额外用量花费",
        "Fetch strategy attempts": "拉取策略尝试",
        "Fetch log": "拉取日志",
        "Five-hour quota": "5 小时配额",
        "Force animation on next refresh": "下次刷新时强制显示动画",
        "General": "通用",
        "Gemini CLI not found": "未找到 Gemini CLI",
        "GitHub Copilot Login": "GitHub Copilot 登录",
        "Hide details": "隐藏详情",
        "Hide personal information": "隐藏个人信息",
        "Install CLI": "安装 CLI",
        "Install the Claude CLI (npm i -g @anthropic-ai/claude-code) and try again.": "请安装 Claude CLI（npm i -g @anthropic-ai/claude-code）后重试。",
        "Install the Gemini CLI (npm i -g @google/gemini-cli) and try again.": "请安装 Gemini CLI（npm i -g @google/gemini-cli）后重试。",
        "Inactive while \"Disable Keychain access\" is enabled in Advanced.": "在“高级”中启用“禁用钥匙串访问”时不可用。",
        "Managed Codex accounts unavailable": "托管 Codex 账户不可用",
        "Managed Codex login did not complete. Try again after finishing the browser login flow.": "托管 Codex 登录没有完成。请完成浏览器登录流程后重试。",
        "Keep CLI sessions alive": "保持 CLI 会话存活",
        "Keyboard shortcut": "键盘快捷键",
        "Keychain access": "钥匙串访问",
        "Label": "标签",
        "Last 30 days": "近 30 天",
        "Launch": "启动",
        "Load parse dump": "加载解析转储",
        "Loading animations": "加载动画",
        "Logging": "日志",
        "Login Failed": "登录失败",
        "Login shell PATH (startup capture)": "登录 shell PATH（启动时捕获）",
        "Manual": "手动",
        "May your tokens never run out—keep agent limits in view.": "愿你的 token 永不耗尽 - 随时掌握智能体限额。",
        "Menu bar": "菜单栏",
        "Menu bar metric": "菜单栏指标",
        "Menu bar shows percent": "菜单栏显示百分比",
        "Menu content": "菜单内容",
        "Merge Icons": "合并图标",
        "Monthly": "月度",
        "Near full": "接近满额",
        "No data available": "暂无数据",
        "No cost history data.": "暂无费用历史数据。",
        "No credits history data.": "暂无积分历史数据。",
        "No enabled providers available for Overview.": "没有可用于概览的已启用服务。",
        "No fetch attempts yet.": "暂无拉取尝试。",
        "No limit set for the API key": "未给该 API Key 设置限额",
        "No log yet. Fetch to load.": "暂无日志。请先拉取。",
        "No log yet. Update OpenAI cookies in Providers → Codex to run an import.": "暂无日志。请在“服务 -> Codex”里更新 OpenAI cookies 以执行导入。",
        "No overview data available.": "暂无概览数据。",
        "No providers selected for Overview.": "概览页尚未选择服务。",
        "No providers selected": "未选择服务",
        "No system account": "没有系统账户",
        "No token accounts yet.": "暂无 token 账户。",
        "No usage breakdown data.": "暂无用量明细数据。",
        "No usage configured.": "尚未配置用量监控。",
        "No usage yet": "暂无用量",
        "No output captured.": "未捕获到输出。",
        "Not found": "未找到",
        "Not fetched yet": "尚未拉取",
        "Notifications": "通知",
        "OK": "确定",
        "Open API Keys": "打开 API Keys",
        "Open Amp Settings": "打开 Amp 设置",
        "Open Antigravity to sign in, then refresh CodexBar.": "打开 Antigravity 登录，然后刷新 CodexBar。",
        "Open Augment (Log Out & Back In)": "打开 Augment（退出后重新登录）",
        "Open Browser": "打开浏览器",
        "Open Coding Plan": "打开 Coding Plan",
        "Open Console": "打开控制台",
        "Open Dashboard": "打开看板",
        "Open Droid in Browser...": "在浏览器中打开 Droid...",
        "Open log file": "打开日志文件",
        "Open menu": "打开菜单",
        "Open Mistral Admin": "打开 Mistral 管理后台",
        "Open Ollama Settings": "打开 Ollama 设置",
        "Open Terminal": "打开终端",
        "Open Usage Page": "打开用量页面",
        "Open Warp API Key Guide": "打开 Warp API Key 指南",
        "OpenAI cookies": "OpenAI cookies",
        "OpenAI web extras": "OpenAI Web 额外数据",
        "OpenCode cookies are disabled.": "OpenCode cookies 已禁用。",
        "OpenCode Go cookies are disabled.": "OpenCode Go cookies 已禁用。",
        "Open token file": "打开 token 文件",
        "Options": "选项",
        "Overview": "概览",
        "Overview rows always follow provider order.": "概览行始终按照服务排序显示。",
        "Overview tab providers": "概览页服务",
        "Percent": "百分比",
        "Pace": "节奏",
        "Both": "两者",
        "Plan": "套餐",
        "Please complete the login in your browser.\nThis window will close automatically when finished.": "请在浏览器里完成登录。\n完成后此窗口会自动关闭。",
        "Post depleted": "发送耗尽通知",
        "Post restored": "发送恢复通知",
        "Provider": "服务",
        "Providers": "服务",
        "Probe logs": "探测日志",
        "Quit": "退出",
        "Quit CodexBar": "退出 CodexBar",
        "Quota usage": "配额用量",
        "Random (default)": "随机（默认）",
        "Re-auth": "重新认证",
        "Re-authenticating…": "正在重新认证...",
        "Receive only stable, production-ready releases.": "仅接收稳定、可用于生产的版本。",
        "Receive stable releases plus beta previews.": "接收稳定版本和 Beta 预览版。",
        "Refresh Session": "刷新会话",
        "Show remaining/used percentage (e.g. 45%)": "显示剩余/已用百分比（例如 45%）",
        "Show pace indicator (e.g. +5%)": "显示节奏指示（例如 +5%）",
        "Show both percentage and pace (e.g. 45% · +5%)": "同时显示百分比和节奏（例如 45% · +5%）",
        "Refresh": "刷新",
        "Refresh cadence": "刷新频率",
        "Refreshing": "正在刷新",
        "Refreshing...": "正在刷新...",
        "Reload": "重新加载",
        "Remove": "移除",
        "Remove Codex account?": "移除 Codex 账户？",
        "Reorder": "重新排序",
        "Replay selected animation": "重放选中动画",
        "Requests": "请求",
        "Reset CLI sessions": "重置 CLI 会话",
        "Save to file": "保存到文件",
        "Select a provider": "选择一个服务",
        "Set cost error": "设置费用错误",
        "Set menu error": "设置菜单错误",
        "Session": "会话",
        "Session quota notifications": "会话配额通知",
        "Settings": "设置",
        "Settings...": "设置...",
        "Show details": "显示详情",
        "Show Debug Settings": "显示调试设置",
        "Show all token accounts": "显示全部 token 账户",
        "Show cost summary": "显示费用摘要",
        "Show credits + extra usage": "显示积分和额外用量",
        "Show most-used provider": "显示用量最高的服务",
        "Show peak hours indicator": "显示高峰时段指示",
        "Show whether Claude is in peak usage hours.": "显示 Claude 是否处于用量高峰时段。",
        "Show reset time as clock": "用时钟显示重置时间",
        "Show usage as used": "用“已用”方式显示用量",
        "Source": "来源",
        "Start at Login": "登录时启动",
        "State": "状态",
        "Status": "状态",
        "Status Page": "状态页",
        "Stable": "稳定版",
        "Subscription Utilization": "订阅使用率",
        "Surprise me": "给我一点惊喜",
        "Switcher shows icons": "切换器显示图标",
        "Symlink CodexBarCLI to /usr/local/bin and /opt/homebrew/bin as codexbar.": "将 CodexBarCLI 作为 codexbar 链接到 /usr/local/bin 和 /opt/homebrew/bin。",
        "System": "系统",
        "(System)": "（系统）",
        "The default Codex account on this Mac.": "这台 Mac 上的默认 Codex 账户。",
        "Tokens": "Token",
        "Total": "总量",
        "Trigger the menu bar menu from anywhere.": "可在任何位置触发菜单栏菜单。",
        "To use Vertex AI tracking, you need to authenticate with Google Cloud.\n\n1. Open Terminal\n2. Run: gcloud auth application-default login\n3. Follow the browser prompts to sign in\n4. Set your project: gcloud config set project PROJECT_ID\n\nWould you like to open Terminal now?": "要使用 Vertex AI 跟踪，需要先通过 Google Cloud 认证。\n\n1. 打开终端\n2. 运行：gcloud auth application-default login\n3. 按浏览器提示登录\n4. 设置项目：gcloud config set project PROJECT_ID\n\n现在要打开终端吗？",
        "Token Refreshed": "Token 已刷新",
        "Unavailable": "不可用",
        "Updates unavailable in this build.": "此构建不可用更新功能。",
        "Update Channel": "更新通道",
        "Update ready, restart now?": "更新已就绪，立即重启？",
        "Updated": "已更新",
        "Usage": "用量",
        "Usage Dashboard": "用量看板",
        "Usage breakdown": "用量明细",
        "Usage history (30 days)": "用量历史（30 天）",
        "Credits history": "积分历史",
        "Usage remaining": "剩余用量",
        "Usage source": "用量来源",
        "Usage used": "已用用量",
        "Use a single menu bar icon with a provider switcher.": "使用一个菜单栏图标，并通过服务切换器查看各服务。",
        "Using CLI fallback": "正在使用 CLI 兜底方案",
        "Vertex AI Login": "Vertex AI 登录",
        "Verbosity": "日志详细度",
        "Version": "版本",
        "Waiting for Authentication...": "等待认证...",
        "Wait for the current managed Codex login to finish before adding another account.": "请等待当前托管 Codex 登录完成后再添加其他账户。",
        "Weekly": "每周",
        "Weekly limit confetti": "周限额恢复彩带",
        "Weekly tokens": "每周 token",
        "Website": "网站",
        "Window": "窗口",
        "Weekly token quota regenerates continuously.": "每周 token 配额会持续恢复。",
        "You can return to the app; authentication finished.": "认证已完成，可以返回应用。",
        "last fetch failed": "最近拉取失败",
        "usage not fetched yet": "尚未拉取用量",
    ]
}

func L(_ text: String) -> String {
    CodexBarL10n.tr(text)
}

func LText(_ text: String) -> Text {
    Text(verbatim: L(text))
}

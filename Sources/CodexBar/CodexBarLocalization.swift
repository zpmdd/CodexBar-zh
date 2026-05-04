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
        "API key": "API Key",
        "API region": "API 区域",
        "API token": "API token",
        "Applies only to the Security.framework OAuth keychain reader.": "仅适用于 Security.framework OAuth 钥匙串读取器。",
        "Auto": "自动",
        "Auto falls back to the next source if the preferred one fails.": "首选来源失败时自动回退到下一个来源。",
        "Auto uses API first, then falls back to CLI on auth failures.": "自动优先使用 API，认证失败时回退到 CLI。",
        "Auto-refresh is off; use the menu's Refresh command.": "自动刷新已关闭；请使用菜单里的“刷新”命令。",
        "Auto-refresh: hourly · Timeout: 10m": "自动刷新：每小时 · 超时：10 分钟",
        "Automation": "自动化",
        "Automatic imports browser cookies and local storage tokens.": "自动导入浏览器 cookies 和本地存储 token。",
        "Automatic imports browser cookies and WorkOS tokens.": "自动导入浏览器 cookies 和 WorkOS token。",
        "Automatic imports browser cookies for dashboard extras.": "自动导入浏览器 cookies，用于看板额外数据。",
        "Automatic imports browser cookies for the web API.": "自动导入浏览器 cookies，用于 Web API。",
        "Automatic imports browser cookies from admin.mistral.ai.": "自动从 admin.mistral.ai 导入浏览器 cookies。",
        "Automatic imports browser cookies from Model Studio/Bailian.": "自动从 Model Studio/百炼导入浏览器 cookies。",
        "Automatic imports browser cookies from opencode.ai.": "自动从 opencode.ai 导入浏览器 cookies。",
        "Automatic imports browser cookies or stored sessions.": "自动导入浏览器 cookies 或已保存会话。",
        "Automatic imports browser cookies.": "自动导入浏览器 cookies。",
        "Automatically imports browser session cookie.": "自动导入浏览器会话 cookie。",
        "Automatically opens CodexBar when you start your Mac.": "启动 Mac 时自动打开 CodexBar。",
        "Avoid Keychain prompts": "避免钥匙串提示",
        "Balance": "余额",
        "Battery Saver": "省电模式",
        "Beta": "Beta 版",
        "Blink now": "立即闪烁",
        "Built": "构建于",
        "Buy Credits...": "购买积分...",
        "Caches": "缓存",
        "Cancel": "取消",
        "Check for updates automatically": "自动检查更新",
        "Check for Updates…": "检查更新...",
        "Check provider status": "检查服务状态",
        "Check if you like your agents having some fun up there.": "让菜单栏里的智能体偶尔活跃一下。",
        "Choose the MiniMax host (global .io or China mainland .com).": "选择 MiniMax 主机（全球 .io 或中国大陆 .com）。",
        "Choose Codex workspace": "选择 Codex 工作区",
        "Choose which window drives the menu bar percent.": "选择菜单栏百分比使用哪个窗口。",
        "Choose which Codex account CodexBar should follow.": "选择 CodexBar 要跟随的 Codex 账户。",
        "Choose what to show in the menu bar (Pace shows usage vs. expected).": "选择菜单栏显示内容；“节奏”会显示实际用量与预期用量的对比。",
        "Clear cost cache": "清除费用缓存",
        "Clear cost error": "清除费用错误",
        "Clear menu error": "清除菜单错误",
        "Cleared.": "已清除。",
        "CLI paths": "CLI 路径",
        "CLI sessions": "CLI 会话",
        "Code review": "代码审查",
        "Cookie source": "Cookie 来源",
        "Cookie header": "Cookie header",
        "Claude cookies": "Claude cookies",
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
        "Custom Path": "自定义路径",
        "Debug": "调试",
        "Display": "显示",
        "Display mode": "显示模式",
        "Display reset times as absolute clock values instead of countdowns.": "用绝对时钟时间显示重置时间，而不是倒计时。",
        "Disable OpenAI dashboard cookie usage.": "禁用 OpenAI 看板 cookie 用法。",
        "Disable Keychain access": "禁用钥匙串访问",
        "Disable all Keychain reads and writes. Browser cookie import is unavailable; paste Cookie headers manually in Providers.": "禁用所有钥匙串读写。浏览器 cookie 导入将不可用；请在“服务”中手动粘贴 Cookie headers。",
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
        "Gateway region": "网关区域",
        "General": "通用",
        "Gemini CLI not found": "未找到 Gemini CLI",
        "GitHub Copilot Login": "GitHub Copilot 登录",
        "GitHub Login": "GitHub 登录",
        "Historical tracking": "历史跟踪",
        "Hide details": "隐藏详情",
        "Hide personal information": "隐藏个人信息",
        "How often CodexBar polls providers in the background.": "CodexBar 后台轮询各服务的频率。",
        "Install CLI": "安装 CLI",
        "Install the Claude CLI (npm i -g @anthropic-ai/claude-code) and try again.": "请安装 Claude CLI（npm i -g @anthropic-ai/claude-code）后重试。",
        "Install the Gemini CLI (npm i -g @google/gemini-cli) and try again.": "请安装 Gemini CLI（npm i -g @google/gemini-cli）后重试。",
        "Inactive while \"Disable Keychain access\" is enabled in Advanced.": "在“高级”中启用“禁用钥匙串访问”时不可用。",
        "JetBrains IDE": "JetBrains IDE",
        "Managed Codex accounts unavailable": "托管 Codex 账户不可用",
        "Managed Codex login did not complete. Try again after finishing the browser login flow.": "托管 Codex 登录没有完成。请完成浏览器登录流程后重试。",
        "Keep CLI sessions alive": "保持 CLI 会话存活",
        "Keyboard shortcut": "键盘快捷键",
        "Keychain access": "钥匙串访问",
        "Keychain prompt policy": "钥匙串提示策略",
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
        "MCP details": "MCP 详情",
        "Menu bar": "菜单栏",
        "Menu bar auto-shows the provider closest to its rate limit.": "菜单栏会自动显示最接近限额的服务。",
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
        "No Codex accounts detected yet.": "尚未检测到 Codex 账户。",
        "No providers selected for Overview.": "概览页尚未选择服务。",
        "No providers selected": "未选择服务",
        "No system account": "没有系统账户",
        "No token accounts yet.": "暂无 token 账户。",
        "Notifies when the 5-hour session quota hits 0% and when it becomes available again.": "5 小时会话配额降到 0% 或恢复可用时发送通知。",
        "No usage breakdown data.": "暂无用量明细数据。",
        "No usage configured.": "尚未配置用量监控。",
        "No usage yet": "暂无用量",
        "No output captured.": "未捕获到输出。",
        "Not found": "未找到",
        "Not fetched yet": "尚未拉取",
        "Notifications": "通知",
        "OK": "确定",
        "Optional override if workspace lookup fails.": "工作区查找失败时可在这里手动指定。",
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
        "Obscure email addresses in the menu bar and menu UI.": "在菜单栏和菜单界面中隐藏邮箱地址。",
        "Override auto-detection with a custom IDE base path": "使用自定义 IDE 基础路径覆盖自动检测。",
        "Overview": "概览",
        "Overview rows always follow provider order.": "概览行始终按照服务排序显示。",
        "Overview tab providers": "概览页服务",
        "Percent": "百分比",
        "Pace": "节奏",
        "Both": "两者",
        "Paste a Cookie header captured from the billing page.": "粘贴从账单页面请求中捕获的 Cookie header。",
        "Paste a Cookie header from a chatgpt.com request.": "粘贴来自 chatgpt.com 请求的 Cookie header。",
        "Paste a Cookie header from a claude.ai request.": "粘贴来自 claude.ai 请求的 Cookie header。",
        "Paste a Cookie header from a cursor.com request.": "粘贴来自 cursor.com 请求的 Cookie header。",
        "Paste a Cookie header from app.factory.ai.": "粘贴来自 app.factory.ai 请求的 Cookie header。",
        "Paste a Cookie header from modelstudio.console.alibabacloud.com.": "粘贴来自 modelstudio.console.alibabacloud.com 请求的 Cookie header。",
        "Paste a Cookie header or cURL capture from Amp settings.": "粘贴从 Amp 设置中捕获的 Cookie header 或 cURL。",
        "Paste a Cookie header or cURL capture from Ollama settings.": "粘贴从 Ollama 设置中捕获的 Cookie header 或 cURL。",
        "Paste a Cookie header or cURL capture from the Abacus AI dashboard.": "粘贴从 Abacus AI 看板中捕获的 Cookie header 或 cURL。",
        "Paste a Cookie header or cURL capture from the Augment dashboard.": "粘贴从 Augment 看板中捕获的 Cookie header 或 cURL。",
        "Paste a Cookie header or cURL capture from the Coding Plan page.": "粘贴从 Coding Plan 页面中捕获的 Cookie header 或 cURL。",
        "Paste the Cookie header from a request to admin.mistral.ai. Must contain an ory_session_* cookie.": "粘贴来自 admin.mistral.ai 请求的 Cookie header，必须包含 ory_session_* cookie。",
        "Play full-screen confetti when weekly usage resets.": "每周用量重置时播放全屏彩带效果。",
        "Plan": "套餐",
        "Please complete the login in your browser.\nThis window will close automatically when finished.": "请在浏览器里完成登录。\n完成后此窗口会自动关闭。",
        "Polls OpenAI/Claude status pages and Google Workspace for Gemini/Antigravity, surfacing incidents in the icon and menu.": "轮询 OpenAI/Claude 状态页以及 Gemini/Antigravity 的 Google Workspace 状态，并在图标和菜单中提示事故。",
        "Post depleted": "发送耗尽通知",
        "Post restored": "发送恢复通知",
        "Prevents any Keychain access while enabled.": "启用后阻止任何钥匙串访问。",
        "Provider": "服务",
        "Providers": "服务",
        "Probe logs": "探测日志",
        "Progress bars fill as you consume quota (instead of showing remaining).": "进度条随配额消耗逐步填充，而不是显示剩余量。",
        "Quit": "退出",
        "Quit CodexBar": "退出 CodexBar",
        "Quota usage": "配额用量",
        "Random (default)": "随机（默认）",
        "Re-auth": "重新认证",
        "Re-authenticating…": "正在重新认证...",
        "Receive only stable, production-ready releases.": "仅接收稳定、可用于生产的版本。",
        "Receive stable releases plus beta previews.": "接收稳定版本和 Beta 预览版。",
        "Refresh Session": "刷新会话",
        "Re-run provider autodetect": "重新运行服务自动检测",
        "Reads local usage logs. Shows today + last 30 days cost in the menu.": "读取本地用量日志，在菜单中显示今日和近 30 天费用。",
        "Replace critter bars with provider branding icons and a percentage.": "用服务品牌图标和百分比替代用量条。",
        "Secure": "安全输入",
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
        "Select the IDE to monitor": "选择要监控的 IDE",
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
        "Show Codex Credits and Claude Extra usage sections in the menu.": "在菜单中显示 Codex 积分和 Claude 额外用量区块。",
        "Show most-used provider": "显示用量最高的服务",
        "Show peak hours indicator": "显示高峰时段指示",
        "Show whether Claude is in peak usage hours.": "显示 Claude 是否处于用量高峰时段。",
        "Show provider icons in the switcher (otherwise show a weekly progress line).": "在切换器中显示服务图标，否则显示每周进度线。",
        "Show reset time as clock": "用时钟显示重置时间",
        "Show usage as used": "用“已用”方式显示用量",
        "Simulated error text": "模拟错误文本",
        "Skip teardown between probes (debug-only).": "探测之间跳过清理流程（仅调试）。",
        "Source": "来源",
        "Start at Login": "登录时启动",
        "State": "状态",
        "Status": "状态",
        "Status Page": "状态页",
        "Stable": "稳定版",
        "Stack token accounts in the menu (otherwise show an account switcher bar).": "在菜单中堆叠显示 token 账户，否则显示账户切换栏。",
        "Stored in ~/.codexbar/config.json. Generate one at kimi-k2.ai.": "存储在 ~/.codexbar/config.json。可在 kimi-k2.ai 生成。",
        "Stored in ~/.codexbar/config.json. Get your key from openrouter.ai/settings/keys and set a key spending limit there to enable API key quota tracking.": "存储在 ~/.codexbar/config.json。请从 openrouter.ai/settings/keys 获取密钥，并在那里设置 key spending limit 以启用 API Key 配额跟踪。",
        "Stored in ~/.codexbar/config.json. In Warp, open Settings > Platform > API Keys, then create one.": "存储在 ~/.codexbar/config.json。在 Warp 中打开 Settings > Platform > API Keys，然后创建一个密钥。",
        "Stored in ~/.codexbar/config.json. Paste the key from the Synthetic dashboard.": "存储在 ~/.codexbar/config.json。粘贴 Synthetic 看板中的密钥。",
        "Stored in ~/.codexbar/config.json. Paste your Coding Plan API key from Model Studio.": "存储在 ~/.codexbar/config.json。粘贴 Model Studio 中的 Coding Plan API Key。",
        "Stored in ~/.codexbar/config.json. Paste your MiniMax API key.": "存储在 ~/.codexbar/config.json。粘贴你的 MiniMax API Key。",
        "Stored in ~/.codexbar/config.json. You can also provide KILO_API_KEY or ~/.local/share/kilo/auth.json (kilo.access).": "存储在 ~/.codexbar/config.json。也可以提供 KILO_API_KEY 或 ~/.local/share/kilo/auth.json（kilo.access）。",
        "Stores local Codex usage history (8 weeks) to personalize Pace predictions.": "保存本地 Codex 用量历史（8 周），用于个性化节奏预测。",
        "Subscription Utilization": "订阅使用率",
        "Surprise me": "给我一点惊喜",
        "Switcher shows icons": "切换器显示图标",
        "Symlink CodexBarCLI to /usr/local/bin and /opt/homebrew/bin as codexbar.": "将 CodexBarCLI 作为 codexbar 链接到 /usr/local/bin 和 /opt/homebrew/bin。",
        "System": "系统",
        "(System)": "（系统）",
        "Temporarily shows the loading animation after the next refresh.": "下次刷新后临时显示加载动画。",
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
        "Use BigModel for the China mainland endpoints (open.bigmodel.cn).": "中国大陆端点（open.bigmodel.cn）使用 BigModel。",
        "Use international or China mainland console gateways for quota fetches.": "用国际版或中国大陆控制台网关拉取配额。",
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
        "Workspace ID": "工作区 ID",
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

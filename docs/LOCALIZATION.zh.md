# CodexBar 本地化维护说明

## 目标

二版本地化采用原生资源文件，尽量贴近上游项目形态。应用名称保持 `CodexBar`，中文通过语言设置启用，不再依赖单独的 `CodexBar 中文.app`。

## 资源位置

- App：`Sources/CodexBar/Resources/Localizable.xcstrings`
- Widget：`Sources/CodexBarWidget/Resources/Localizable.xcstrings`
- CLI：`Sources/CodexBarCLI/Resources/Localizable.xcstrings`

优先把新增用户可见文案放入对应 String Catalog。SwiftUI 静态文案使用原生 `Text("...")` / `Label("...")`；AppKit、动态字符串和 CLI 输出使用本地化桥接函数。

## 语言选择

语言偏好由 `AppLanguagePreference` 管理：

- `system`：跟随系统。
- `english`：强制英文。
- `simplifiedChinese`：强制简体中文。

解析顺序：

1. `CODEXBAR_LANG` 环境变量。
2. UserDefaults 中的 `appLanguagePreference`。
3. 系统首选语言。

## 回退策略

中文翻译缺失时必须返回英文原文。不要返回空字符串，不要展示内部 key，不要阻塞菜单、Widget 或 CLI 输出。

动态文案只处理稳定模式，例如：

- `33% in reserve`
- `7% in deficit`
- `Runs out in 3d`
- `Partial System Degradation - Updated 5:59`

匹配不到的动态内容保持英文。

## 同步上游

```bash
git fetch upstream
git rebase upstream/main
swift test
./Scripts/compile_and_run.sh
```

同步后检查新增英文文案：

- App 菜单和设置页：优先补 `Sources/CodexBar/Resources/Localizable.xcstrings`。
- Widget 文案：同步补 `Sources/CodexBarWidget/Resources/Localizable.xcstrings`。
- CLI 文案：同步补 `Sources/CodexBarCLI/Resources/Localizable.xcstrings`。

如果来不及翻译，先保留英文原文，保证功能可用。

## 验证

重点测试：

```bash
swift test --filter CodexBarLocalizationTests
swift test --filter AppLanguagePreferenceTests
swift test --filter CodexBarWidgetProviderTests
swift test --filter CLICostTests
```

截图更新：

```bash
CODEXBAR_WRITE_SCREENSHOTS=1 swift test --filter ChineseScreenshotRenderTests
```

截图前确认 `hidePersonalInfo` 启用，避免真实账号进入仓库图片。

## Codex OpenAI Web 排障文案

Codex OpenAI Web 额外数据会影响主菜单里的“积分”、购买积分入口、费用/用量历史以及“会话/每周”右侧柱状图。相关错误需要保持中文用户可理解：

- Dashboard 空页面：说明用户需要登录 `chatgpt.com` 并刷新 OpenAI cookies。
- 会话图表缺失：通常是 Dashboard 没有抓到 `usageBreakdown`，不要描述成菜单渲染失败。
- 钥匙串提示：说明需要允许 Chrome Safe Storage，或改用手动 Cookie。
- 重新认证失败：如果错误来自 `~/.codex/config.toml`，要明确这是 Codex CLI 配置问题，不是中文本地化或 Dashboard 抓取问题。

实现上 Codex OpenAI Web 自动导入优先使用 Chrome，并保留 Safari/Firefox 回退。同步上游时如果 cookie 导入顺序、Dashboard URL、User-Agent 或 `OpenAIDashboardScrapeScript` 发生变化，需要同时复查这些中文说明。

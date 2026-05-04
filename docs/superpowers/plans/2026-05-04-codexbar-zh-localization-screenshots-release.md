# CodexBar 中文主菜单修复与发布 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修复主菜单和图表中仍显示英文的用户可见文案，补齐截图和 README，并把可免 Xcode 安装的中文版本发布到 GitHub。

**Architecture:** 汉化仍集中在 `Sources/CodexBar/CodexBarLocalization.swift`，视图层只在原本绕过 `LText` 的地方接入 `L(...)`/`LText(...)`。发布路径分成普通用户预构建包和维护者源码构建两条线，普通用户默认走 GitHub Release 下载。

**Tech Stack:** SwiftUI、Swift Testing、SwiftPM、macOS `screencapture`、GitHub CLI。

---

### Task 1: 主菜单漏翻根因定位

**Files:**
- Inspect: `Sources/CodexBar/UsagePaceText.swift`
- Inspect: `Sources/CodexBar/UsageBreakdownChartMenuView.swift`
- Inspect: `Sources/CodexBar/CreditsHistoryChartMenuView.swift`
- Inspect: `Sources/CodexBar/MenuDescriptor.swift`
- Inspect: `Sources/CodexBar/Providers/Codex/CodexProviderImplementation.swift`
- Inspect: `Sources/CodexBar/CodexBarLocalization.swift`

- [ ] **Step 1: 搜索用户红框文案来源**

Run:

```bash
rg -n "in reserve|Lasts until reset|Hover a bar for details|Desktop App|Jetbrains|System Account|Partial System Degradation|Updated" Sources Tests
```

Expected: 查到 `UsagePaceText.swift`、图表视图、状态行、Codex provider action 菜单。

- [ ] **Step 2: 判断漏翻类型**

Expected:

```text
UsagePaceText.swift: 生成动态节奏文案，本身返回英文，再由 MetricRow 的 LText 动态翻译。
UsageBreakdownChartMenuView.swift / CreditsHistoryChartMenuView.swift: detail 区域直接 Text(...)，没有走 LText。
MenuDescriptor.swift: 状态行拼接英文状态接口 description + Updated freshness。
CodexProviderImplementation.swift: System Account 是固定标题，当前词典未覆盖。
OpenAIDashboard service labels: Desktop App / Jetbrains 是后端服务名，需要词典或标准化函数覆盖。
```

### Task 2: 补测试锁住红框文案

**Files:**
- Modify: `Tests/CodexBarTests/CodexBarLocalizationTests.swift`

- [ ] **Step 1: 加入动态主菜单文案测试**

Add expectations:

```swift
#expect(CodexBarL10n.tr("33% in reserve") == "预留 33%")
#expect(CodexBarL10n.tr("Lasts until reset") == "可持续到重置")
#expect(CodexBarL10n.tr("Runs out in 3d") == "将在 3天后耗尽")
#expect(CodexBarL10n.tr("Hover a bar for details") == "悬停柱形查看详情")
```

- [ ] **Step 2: 加入服务名和状态行测试**

Add expectations:

```swift
#expect(CodexBarL10n.tr("Desktop App") == "桌面应用")
#expect(CodexBarL10n.tr("Jetbrains") == "JetBrains")
#expect(CodexBarL10n.tr("System Account") == "系统账户")
#expect(CodexBarL10n.tr("Partial System Degradation — Updated 5:59") == "部分系统降级 - 更新于 5:59")
```

- [ ] **Step 3: 跑失败测试确认覆盖**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter CodexBarLocalizationTests
```

Expected: 当前代码至少在新增红框英文测试上失败。

### Task 3: 实现主菜单汉化修复

**Files:**
- Modify: `Sources/CodexBar/CodexBarLocalization.swift`
- Modify: `Sources/CodexBar/UsageBreakdownChartMenuView.swift`
- Modify: `Sources/CodexBar/CreditsHistoryChartMenuView.swift`

- [ ] **Step 1: 在动态翻译中支持节奏文案**

Implementation targets:

```swift
if text.hasSuffix("% in reserve") { return "预留 \(number)%" }
if text.hasSuffix("% in deficit") { return "超前消耗 \(number)%" }
if text.hasPrefix("Runs out in ") { return "将在 \(translatedDuration)后耗尽" }
if text == "Lasts until reset" { return "可持续到重置" }
if text == "Hover a bar for details" { return "悬停柱形查看详情" }
```

- [ ] **Step 2: 在动态翻译中支持状态行**

Implementation targets:

```swift
if text.contains(" — Updated ") {
    return "\(translatedStatus) - 更新于 \(translatedTime)"
}
```

Statuses to cover now:

```text
Partial System Degradation -> 部分系统降级
Degraded performance -> 性能下降
Major System Outage -> 重大系统中断
Minor Service Outage -> 局部服务中断
All Systems Operational -> 所有系统正常
```

- [ ] **Step 3: 图表 detail 从 Text 改为 LText**

Change both chart detail blocks so `detail.primary` and `detail.secondary` pass through localization:

```swift
LText(detail.primary)
LText(detail.secondary ?? " ")
```

- [ ] **Step 4: 加入固定词典项**

Add:

```swift
"Desktop App": "桌面应用",
"Jetbrains": "JetBrains",
"System Account": "系统账户",
"Lasts until reset": "可持续到重置",
"Hover a bar for details": "悬停柱形查看详情",
```

### Task 4: 定向验证

**Files:**
- Test: `Tests/CodexBarTests/CodexBarLocalizationTests.swift`
- Test: `Tests/CodexBarTests/UsagePaceTextTests.swift`

- [ ] **Step 1: 跑汉化测试**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter CodexBarLocalizationTests
```

Expected: PASS。

- [ ] **Step 2: 跑节奏文案测试，确认未破坏模型层英文基线**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter UsagePaceTextTests
```

Expected: PASS。模型层仍可输出英文，视图层通过 `LText` 汉化。

### Task 5: 本地安装和主菜单人工检查

**Files:**
- Use: `Scripts/install_zh_app.sh`

- [ ] **Step 1: 安装中文构建**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./Scripts/install_zh_app.sh
```

Expected: `/Applications/CodexBar 中文.app` 启动，`codesign --verify --deep --strict` 通过。

- [ ] **Step 2: 打开主菜单检查红框区域**

Expected visible Chinese:

```text
预留 36%
可持续到重置
悬停柱形查看详情
桌面应用
JetBrains
系统账户
部分系统降级 - 更新于 ...
```

### Task 6: 中文页面截图

**Files:**
- Create/Update: `docs/screenshots/zh-menu.png`
- Create/Update: `docs/screenshots/zh-display.png`
- Create/Update: `docs/screenshots/zh-advanced.png`
- Create/Update: `docs/screenshots/zh-about.png`

- [ ] **Step 1: 使用脱敏演示数据生成主菜单截图**

Run:

```bash
CODEXBAR_WRITE_SCREENSHOTS=1 DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter ChineseScreenshotRenderTests
```

Expected: 截图中主菜单关键区域为中文，账号显示为 `Hidden`，不包含真实 GPT/OpenAI 账号。

- [ ] **Step 2: 保存设置页截图**

Expected: 覆盖“显示”“高级”“关于”页面，用于 README 展示汉化质量；不要提交包含真实邮箱的 `zh-providers.png`。

### Task 7: README 和项目介绍更新

**Files:**
- Modify: `README.md`

- [ ] **Step 1: 加入界面预览章节**

Add screenshot table:

```markdown
## 界面预览

| 主菜单 | 显示设置 |
| --- | --- |
| <img src="docs/screenshots/zh-menu.png" width="420"> | <img src="docs/screenshots/zh-display.png" width="420"> |
```

- [ ] **Step 2: 确认安装默认路径无需 Xcode**

Expected: README 默认安装方式是 GitHub Release 预构建包；源码构建只在开发者章节出现。

### Task 8: 预构建包和 GitHub 发布

**Files:**
- Use: `Scripts/package_zh_release.sh`
- Use: `dist/CodexBar-zh-macos-universal.zip`
- Use: `dist/CodexBar-zh-macos-universal.zip.sha256`

- [ ] **Step 1: 生成 Release 包**

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./Scripts/package_zh_release.sh
```

Expected:

```text
Created dist/CodexBar-zh-macos-universal.zip
Checksum: dist/CodexBar-zh-macos-universal.zip.sha256
```

- [ ] **Step 2: 提交并推送源码变更**

Run:

```bash
git status --short
git add README.md Sources/CodexBar/CodexBarLocalization.swift Sources/CodexBar/UsageBreakdownChartMenuView.swift Sources/CodexBar/CreditsHistoryChartMenuView.swift Tests/CodexBarTests/CodexBarLocalizationTests.swift Scripts/package_app.sh Scripts/package_zh_release.sh Scripts/install_latest_zh.sh docs/screenshots docs/superpowers/plans
git commit -m "Improve Chinese menu localization and release install flow"
git push origin main
```

Expected: push 成功，工作区干净。

- [ ] **Step 3: 创建或更新 GitHub Release**

Run:

```bash
gh release create v0.24-zh.1 dist/CodexBar-zh-macos-universal.zip dist/CodexBar-zh-macos-universal.zip.sha256 --repo zpmdd/CodexBar-zh --title "CodexBar 中文版 0.24-zh.1" --notes-file dist/RELEASE_NOTES.md
```

Expected: GitHub Release 可下载，README 的一键安装脚本可访问 latest asset。

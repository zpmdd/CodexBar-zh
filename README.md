# CodexBar 简体中文本地化 / Simplified Chinese Localization

<p align="center">
  <a href="https://github.com/steipete/CodexBar">上游项目</a>
  ·
  <a href="#english-overview">English</a>
  ·
  <a href="#安装">安装</a>
  ·
  <a href="#界面预览">界面预览</a>
  ·
  <a href="#语言切换">语言切换</a>
  ·
  <a href="#codex-openai-web-额外数据">Codex OpenAI Web</a>
  ·
  <a href="#上游同步">上游同步</a>
</p>

<p align="center">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-blue">
  <img alt="Platform" src="https://img.shields.io/badge/macOS-14%2B-black">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange">
  <img alt="Localization" src="https://img.shields.io/badge/localization-en%20%7C%20zh--Hans-success">
</p>

## English Overview

This repository is a Simplified Chinese localization fork of [CodexBar](https://github.com/steipete/CodexBar), a macOS menu bar app for monitoring AI agent quota, usage, costs, credits, and provider status.

The v2 localization keeps the app in the official shape: the app is still named `CodexBar`, translations live in native Apple localization resources, and users can switch between `System`, `English`, and `Simplified Chinese` from Settings. When an upstream string has not been translated yet, CodexBar safely falls back to the original English text instead of showing an empty label or a broken key.

Highlights:

- Native English / Simplified Chinese language switch inside the app.
- Localized menu, settings, charts, widgets, dialogs, and human-facing CLI output.
- RMB cost estimates shown together with the original USD and token totals.
- Chrome-first OpenAI Web Dashboard cookie import for Codex session/weekly breakdowns, credits history, and chart details.
- Upstream-friendly localization structure designed to make future CodexBar updates easier to merge.

Install without Xcode:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/Scripts/install_latest_zh.sh)"
```

The installer downloads the latest GitHub Release and installs `/Applications/CodexBar.app`. The current public build is ad-hoc signed, so it is intended as a community localization build rather than an official notarized upstream release.

## 中文概览

本仓库基于 [CodexBar](https://github.com/steipete/CodexBar) 做简体中文本地化。二版不再把应用做成 `CodexBar 中文.app`，而是保持原应用名称 `CodexBar`，通过原生本地化资源和设置内语言切换提供 English / 简体中文 / 跟随系统。

核心目标是减少上游同步成本：新增或变更的英文文案如果还没有中文翻译，会安全显示英文原文，不会出现空白、异常 key 或阻塞应用启动。

## 界面预览

截图使用脱敏演示数据生成，账号信息不会出现在仓库图片中。

| 主菜单 | 显示设置 |
| --- | --- |
| <img src="docs/screenshots/zh-menu.png" alt="CodexBar 中文主菜单" width="430"> | <img src="docs/screenshots/zh-display.png" alt="CodexBar 中文显示设置" width="430"> |

| 高级设置 | 关于 |
| --- | --- |
| <img src="docs/screenshots/zh-advanced.png" alt="CodexBar 中文高级设置" width="430"> | <img src="docs/screenshots/zh-about.png" alt="CodexBar 中文关于页面" width="430"> |

## 主要特性

- 应用名称保持 `CodexBar`，不再使用 `CodexBar 中文`。
- 设置页增加语言选择：`跟随系统`、`English`、`简体中文`。
- App 主菜单、设置页、弹窗、图表、Widget、CLI 文本输出接入本地化。
- CLI 命令名、参数名、JSON 字段保持英文，避免破坏脚本和机器读取。
- 费用区块继续显示人民币估算：`¥金额 · $金额 · tokens`。
- Codex 的 OpenAI Web 额外数据使用 Chrome 优先的 cookie 导入策略，降低 Safari cookie 可识别账号但隐藏 WebView 无法加载 Dashboard 的概率。
- 中文缺失时自动回退英文原文，方便同步上游版本。

## 安装

普通用户无需安装 Xcode，可以直接安装 GitHub Release 中的预构建包：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/Scripts/install_latest_zh.sh)"
```

脚本会下载最新发布包，安装为：

```text
/Applications/CodexBar.app
```

也可以手动下载 `CodexBar-zh-macos-universal.zip`，解压后把 `CodexBar.app` 拖到 `/Applications`。

说明：adhoc 预构建包不是 Apple Developer ID 公证包。安装脚本会清理下载隔离属性，减少首次打开阻拦；如果后续接入正式签名和公证，可以移除这一步。

## 语言切换

打开 `设置 -> 通用 -> 语言`，选择：

- `跟随系统`：按 macOS 首选语言显示，暂时只区分英文和简体中文。
- `English`：强制英文。
- `简体中文`：强制简体中文。

语言切换后，菜单、设置页、弹窗、图表和 Widget 时间线会刷新。系统控制的 Widget Gallery 和 AppIntent 元数据可能需要重新打开系统界面后才显示新语言。

临时调试也可以使用环境变量覆盖：

```bash
CODEXBAR_LANG=en ./CodexBar.app/Contents/MacOS/CodexBar
CODEXBAR_LANG=zh-Hans ./CodexBar.app/Contents/MacOS/CodexBar
```

## 开发与验证

主要本地化入口：

- `Sources/CodexBar/Resources/Localizable.xcstrings`
- `Sources/CodexBarWidget/Resources/Localizable.xcstrings`
- `Sources/CodexBarCLI/Resources/Localizable.xcstrings`
- `Sources/CodexBar/CodexBarLocalization.swift`
- `Sources/CodexBarCore/AppLanguagePreference.swift`

常用命令：

```bash
swift test --filter CodexBarLocalizationTests
swift test --filter AppLanguagePreferenceTests
swift test --filter CodexBarWidgetProviderTests
swift test --filter CLICostTests
./Scripts/compile_and_run.sh
```

本地安装调试：

```bash
./Scripts/install_zh_app.sh
codesign --verify --deep --strict "/Applications/CodexBar.app"
```

生成预构建包：

```bash
./Scripts/package_zh_release.sh
```

产物位于 `dist/`，默认生成 `CodexBar-zh-macos-universal.zip` 和 SHA-256 校验文件。

## Codex OpenAI Web 额外数据

`服务 -> Codex -> OpenAI Web 额外数据` 用于显示 Codex 官方 Dashboard 上的附加信息，例如会话/每周用量明细、积分历史、购买积分入口和右侧柱状图。

实现细节：

- 自动 cookie 导入优先读取 Chrome，然后回退 Safari、Firefox 和其他浏览器。
- 隐藏 WebView 和 OpenAI Dashboard API 使用浏览器型 Chrome User-Agent，避免浏览器 cookie 与请求指纹不一致。
- cookie 缓存在本机 Keychain 中，服务名为 `com.steipete.codexbar.cache`，不会进入仓库或截图。
- 第一次读取 Chrome cookie 时，macOS 可能要求允许访问 `Chrome Safe Storage`。允许后通常不会反复弹出；如果拒绝，OpenAI Web 额外数据可能只能回退到 Safari 或手动 Cookie。

常见问题：

- “积分”提示 Dashboard 空页面，或鼠标悬停“会话”没有右侧柱状图：先确认 Chrome 能打开 `https://chatgpt.com/codex/settings/usage`，然后在 `服务 -> Codex` 点一次刷新/更新 OpenAI cookies。
- 如果 Safari 能打开页面但 App 仍没有图表，优先在 Chrome 登录同一个 ChatGPT/Codex 账号，并允许 CodexBar 访问 Chrome 钥匙串。
- “重新认证”弹出 `missing field command in mcp_servers.figma`：这是本机 `~/.codex/config.toml` 里存在 Codex CLI 不支持的 URL-only MCP 配置。删除或改正该 `[mcp_servers.figma]` 块后再重试。
- 如果 Codex CLI 提示 `unknown variant xhigh`，把 `~/.codex/config.toml` 中的 `model_reasoning_effort` 改为当前 CLI 支持的 `high`。

## 上游同步

推荐同步流程：

```bash
git fetch upstream
git rebase upstream/main
swift test
./Scripts/compile_and_run.sh
```

处理原则：

- 不把中文文案散落在业务逻辑里，新增文案优先进入 `Localizable.xcstrings`。
- 上游新增文案暂时没有中文时，保留英文原文。
- 动态文案只在稳定模式处做格式化翻译，例如用量百分比、重置时间、状态描述。
- 不改变原始 USD 成本、排序、统计和 JSON 字段，人民币只作为显示估算。

## 隐私与权限

CodexBar 的数据来源策略继承自上游项目：读取本机 CLI 状态、日志、浏览器 cookie 或 Keychain token。相关能力按服务开启。

除费用区块按需访问 Frankfurter 免费汇率接口获取 USD/CNY 汇率外，本地化不会额外增加联网、遥测或后台采集逻辑。汇率缓存只保存汇率、汇率日期和抓取时间，不包含账号信息。

## 许可证

MIT。详见 [LICENSE](LICENSE)、[NOTICE.md](NOTICE.md) 和 [docs/LEGAL.zh.md](docs/LEGAL.zh.md)。

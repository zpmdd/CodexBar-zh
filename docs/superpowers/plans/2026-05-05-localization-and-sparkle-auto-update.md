# CodexBar Localization And Sparkle Auto Update Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the two visible Chinese localization gaps and make the Chinese localized CodexBar build support Sparkle automatic updates with the same user-facing experience as upstream.

**Architecture:** Keep the app display name as `CodexBar`. Runtime UI localization uses String Catalog plus `LText`/`L(...)` fallback bridges. Release updates use Sparkle exactly like upstream, but with a Chinese-build update identity: dedicated feed URL, dedicated Sparkle Ed25519 key pair, signed/notarized release archives, and a pre-release upstream-sync gate that preserves existing Chinese strings while leaving new upstream strings in English until translated.

**Tech Stack:** Swift 6, SwiftUI, Swift Charts, SwiftPM resources, Sparkle 2, Developer ID signing, Apple notarization, GitHub Releases, `appcast.xml`, XCTest, shell release scripts.

---

## Corrected Scope

The third requirement is not Git source syncing inside the UI. It is the About page automatic update experience.

Current behavior:

- About page shows `Updates unavailable in this build.`
- `CodexBar.app/Contents/Info.plist` currently has `SUFeedURL=""` and `SUEnableAutomaticChecks=false`.
- `Sources/CodexBar/CodexbarApp.swift` disables Sparkle unless the bundle is a `.app`, not Homebrew, and Developer ID signed.
- `Scripts/package_app.sh` intentionally clears the feed and disables automatic checks for debug and adhoc builds.

Required behavior:

- About page shows the upstream-like update controls:
  - `Check for updates automatically`
  - `Update Channel`
  - `Check for Updates...`
- Chinese release builds can update automatically from our Chinese release feed.
- Updates must never silently replace the Chinese localized app with upstream official English-only assets.

## Key Decisions

1. **Do not use the upstream Sparkle feed for Chinese releases.**
   - Upstream feed URL points to `steipete/CodexBar` assets.
   - Updating from it would replace the localized build with upstream official builds.
   - It also depends on the upstream Sparkle key chain.

2. **Use a Chinese-release Sparkle identity.**
   - Feed: `https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/appcast.xml`
   - Download prefix: `https://github.com/zpmdd/CodexBar-zh/releases/download/v<version>/`
   - Public key: generated for this project and embedded into `SUPublicEDKey`.
   - Private key: kept outside the repository and referenced by `SPARKLE_PRIVATE_KEY_FILE`.

3. **Keep user-facing app name `CodexBar`.**
   - `CFBundleName=CodexBar`
   - `CFBundleDisplayName=CodexBar`
   - Release notes and README may call it the Chinese localized build, but the installed app remains `CodexBar`.

4. **Release builds must be signed and notarized.**
   - Fully automatic Sparkle updates should be enabled only for Developer ID signed release builds.
   - Adhoc builds stay installable for testing but continue to show an unavailable update reason.

5. **Current adhoc installed builds cannot magically self-update.**
   - Because they were built with empty `SUFeedURL` and updater disabled, they need one manual replacement with the first signed Sparkle-enabled Chinese release.
   - After that first signed install, future updates are automatic.

## File Structure

- Modify: `Sources/CodexBar/PlanUtilizationHistoryChartMenuView.swift`
  - Fix `Session`, `Weekly`, date, and `% used` localization in subscription utilization chart.
- Modify: `Sources/CodexBar/CostHistoryChartMenuView.swift`
  - Fix `Hover a bar for details` localization in the cost chart.
- Modify: `Sources/CodexBar/CodexBarLocalization.swift`
  - Add stable dynamic translation coverage for plan-utilization details.
- Modify: `Tests/CodexBarTests/CodexBarLocalizationTests.swift`
  - Add regression coverage for the missing strings.
- Modify: `Tests/CodexBarTests/UsageStorePlanUtilizationDerivedChartTests.swift`
  - Add regression coverage for Chinese utilization detail output.
- Modify: `Scripts/package_app.sh`
  - Parameterize release feed URL, Sparkle public key, bundle ID, team ID, and auto-check behavior.
- Modify: `Scripts/sign-and-notarize.sh`
  - Remove hard-coded Peter Steinberger signing identity for Chinese releases.
  - Require explicit release identity variables.
- Modify: `Scripts/make_appcast.sh`
  - Default to the Chinese release feed and Chinese GitHub release download prefix when `CODEXBAR_RELEASE_REPO=zpmdd/CodexBar-zh`.
- Create: `Scripts/release_zh.sh`
  - End-to-end Chinese release script: clean tree, sync upstream, audit localization, test, sign, notarize, create GitHub release, generate appcast, verify Sparkle signature, publish.
- Create: `Scripts/audit_localization.py`
  - Report missing translations and unsafe direct `Text(...)` usage.
- Modify: `docs/LOCALIZATION.zh.md`
  - Document upstream update adaptation and fallback behavior.
- Modify: `docs/RELEASING.zh.md`
  - Document the Chinese Sparkle release process.
- Modify: `README.md`
  - Explain automatic update availability and the one-time migration from adhoc builds.

## Task 1: Fix Subscription Utilization Localization

**Files:**
- Modify: `Sources/CodexBar/PlanUtilizationHistoryChartMenuView.swift`
- Modify: `Sources/CodexBar/CodexBarLocalization.swift`
- Test: `Tests/CodexBarTests/CodexBarLocalizationTests.swift`
- Test: `Tests/CodexBarTests/UsageStorePlanUtilizationDerivedChartTests.swift`

- [ ] **Step 1: Add localization regression expectations**

Add to the Simplified Chinese localization test:

```swift
AppLanguageRuntime.withPreference(.simplifiedChinese) {
    #expect(CodexBarL10n.tr("Session") == "会话")
    #expect(CodexBarL10n.tr("Weekly") == "每周")
    #expect(CodexBarL10n.tr("Hover a bar for details") == "悬停柱形查看详情")
    #expect(CodexBarL10n.tr("May 5, 11:47 am: 8% used") == "5月5日 11:47：已用 8%")
}
```

Run:

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter CodexBarLocalizationTests
```

Expected before implementation: the `May 5...used` assertion fails.

- [ ] **Step 2: Localize segmented picker labels**

In `PlanUtilizationHistoryChartMenuView.body`, replace:

```swift
Text(series.title).tag(series.id)
```

with:

```swift
LText(series.title).tag(series.id)
```

- [ ] **Step 3: Localize empty and detail lines**

Replace:

```swift
Text(Self.emptyStateText(title: effectiveSelectedSeries?.title))
```

with:

```swift
LText(Self.emptyStateText(title: effectiveSelectedSeries?.title))
```

Replace:

```swift
Text(self.detailLine(model: model, windowMinutes: effectiveSelectedSeries?.history.windowMinutes ?? 0))
```

with:

```swift
LText(self.detailLine(model: model, windowMinutes: effectiveSelectedSeries?.history.windowMinutes ?? 0))
```

- [ ] **Step 4: Format visible chart dates by app language**

Update `detailDateLabel(for:windowMinutes:)`:

```swift
private nonisolated static func detailDateLabel(for date: Date, windowMinutes: Int) -> String {
    let language = AppLanguageRuntime.resolvedPreference().resolvedLocalizationIdentifier()
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone.current
    if language == "zh-Hans" {
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "M月d日 H:mm"
    } else {
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        formatter.dateFormat = "MMM d, h:mm a"
    }
    return formatter.string(from: date)
}
```

- [ ] **Step 5: Add dynamic fallback for old English detail strings**

Add this branch in `CodexBarL10n.dynamicTranslation(_:)` before the generic `hasSuffix(" used")` branch:

```swift
let utilizationPattern = #"^([A-Z][a-z]{2}) (\d{1,2}), (\d{1,2}:\d{2}) (am|pm): ([0-9]+(?:\.[0-9])?)% used$"#
if let regex = try? NSRegularExpression(pattern: utilizationPattern),
   let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
   match.numberOfRanges == 6,
   let monthRange = Range(match.range(at: 1), in: text),
   let dayRange = Range(match.range(at: 2), in: text),
   let timeRange = Range(match.range(at: 3), in: text),
   let ampmRange = Range(match.range(at: 4), in: text),
   let percentRange = Range(match.range(at: 5), in: text)
{
    let monthMap = [
        "Jan": "1", "Feb": "2", "Mar": "3", "Apr": "4",
        "May": "5", "Jun": "6", "Jul": "7", "Aug": "8",
        "Sep": "9", "Oct": "10", "Nov": "11", "Dec": "12",
    ]
    let month = monthMap[String(text[monthRange])] ?? String(text[monthRange])
    let day = String(text[dayRange])
    let time = self.toChineseHour(String(text[timeRange]), ampm: String(text[ampmRange]))
    let percent = String(text[percentRange])
    return "\(month)月\(day)日 \(time)：已用 \(percent)%"
}
```

Add helper:

```swift
private static func toChineseHour(_ time: String, ampm: String) -> String {
    let parts = time.split(separator: ":")
    guard parts.count == 2, var hour = Int(parts[0]) else { return time }
    if ampm == "pm", hour < 12 { hour += 12 }
    if ampm == "am", hour == 12 { hour = 0 }
    return "\(hour):\(parts[1])"
}
```

- [ ] **Step 6: Run targeted verification**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test \
  --filter 'CodexBarLocalizationTests|UsageStorePlanUtilizationDerivedChartTests'
```

Expected: selected suites pass.

## Task 2: Fix Cost Chart Placeholder Localization

**Files:**
- Modify: `Sources/CodexBar/CostHistoryChartMenuView.swift`
- Test: `Tests/CodexBarTests/CodexBarLocalizationTests.swift`

- [ ] **Step 1: Confirm test coverage**

Keep this expectation in `CodexBarLocalizationTests`:

```swift
#expect(CodexBarL10n.tr("Hover a bar for details") == "悬停柱形查看详情")
```

- [ ] **Step 2: Render cost detail primary with `LText`**

In `CostHistoryChartMenuView.body`, replace:

```swift
Text(detail.primary)
```

with:

```swift
LText(detail.primary)
```

Do not change:

```swift
Text(row.title)
Text(subtitle)
```

Reason: `row.title` is usually a model name such as `gpt-5.5`; `subtitle` is formatted money/tokens and must not be translated as a sentence.

- [ ] **Step 3: Run targeted verification**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test --filter CodexBarLocalizationTests
```

Expected: test passes and `Hover a bar for details` maps to `悬停柱形查看详情`.

## Task 3: Enable Safe Sparkle Automatic Updates For Chinese Releases

**Files:**
- Modify: `Scripts/package_app.sh`
- Modify: `Scripts/sign-and-notarize.sh`
- Modify: `Scripts/make_appcast.sh`
- Modify: `Sources/CodexBar/CodexbarApp.swift`
- Modify: `Sources/CodexBar/PreferencesAboutPane.swift`
- Create: `Scripts/release_zh.sh`
- Create: `docs/RELEASING.zh.md`
- Modify: `README.md`
- Test: `Tests/CodexBarTests/UpdaterAvailabilityTests.swift`

- [ ] **Step 1: Add release identity configuration**

Support these environment variables in release scripts:

```bash
export CODEXBAR_RELEASE_REPO="zpmdd/CodexBar-zh"
export CODEXBAR_FEED_URL="https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/appcast.xml"
export SPARKLE_DOWNLOAD_URL_PREFIX="https://github.com/zpmdd/CodexBar-zh/releases/download/v${MARKETING_VERSION}/"
export CODEXBAR_SPARKLE_PUBLIC_ED_KEY="<generated-public-key>"
export SPARKLE_PRIVATE_KEY_FILE="$HOME/.codexbar-release/sparkle-private-key.txt"
export APP_IDENTITY="Developer ID Application: <Your Name> (<TEAMID>)"
export APP_TEAM_ID="<TEAMID>"
export CODEXBAR_BUNDLE_ID="com.zpmdd.codexbar"
```

Recommended default for Chinese public releases:

- App name: `CodexBar`
- Bundle identifier: `com.zpmdd.codexbar`
- Feed URL: `https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/appcast.xml`

If the existing installed Chinese build used `com.steipete.codexbar`, document this as a one-time manual migration. Do not silently update official upstream users into the fork.

- [ ] **Step 2: Parameterize Sparkle public key in `package_app.sh`**

Replace the hard-coded Sparkle key:

```bash
<key>SUPublicEDKey</key><string>AGCY8w5vHirVfGGDGc8Szc5iuOqupZSh9pMj/Qs67XI=</string>
```

with:

```bash
SPARKLE_PUBLIC_ED_KEY="${CODEXBAR_SPARKLE_PUBLIC_ED_KEY:-AGCY8w5vHirVfGGDGc8Szc5iuOqupZSh9pMj/Qs67XI=}"
```

and write:

```bash
<key>SUPublicEDKey</key><string>${SPARKLE_PUBLIC_ED_KEY}</string>
```

- [ ] **Step 3: Keep updater disabled for unsafe builds**

Keep the current behavior for debug and adhoc builds:

```bash
if [[ "$LOWER_CONF" == "debug" ]]; then
  FEED_URL=""
  AUTO_CHECKS=false
fi
if [[ "$SIGNING_MODE" == "adhoc" ]]; then
  FEED_URL=""
  AUTO_CHECKS=false
fi
```

Add a clearer unavailable reason in `makeUpdaterController()`:

```swift
guard isDeveloperIDSigned(bundleURL: bundleURL) else {
    return DisabledUpdaterController(
        unavailableReason: "This local build is not Developer ID signed. Install the signed GitHub release to enable automatic updates.")
}
```

Chinese translation:

```swift
"This local build is not Developer ID signed. Install the signed GitHub release to enable automatic updates.": "此本地构建未使用 Developer ID 签名。请安装已签名的 GitHub Release 版本以启用自动更新。"
```

- [ ] **Step 4: Make `sign-and-notarize.sh` fork-safe**

Replace:

```bash
APP_IDENTITY="Developer ID Application: Peter Steinberger (Y5PE65HELJ)"
```

with:

```bash
APP_IDENTITY="${APP_IDENTITY:?Set APP_IDENTITY to your Developer ID Application identity}"
APP_TEAM_ID="${APP_TEAM_ID:?Set APP_TEAM_ID to your Apple Developer Team ID}"
CODEXBAR_SPARKLE_PUBLIC_ED_KEY="${CODEXBAR_SPARKLE_PUBLIC_ED_KEY:?Set CODEXBAR_SPARKLE_PUBLIC_ED_KEY}"
```

Call `package_app.sh` with explicit release identity:

```bash
APP_IDENTITY="$APP_IDENTITY" \
APP_TEAM_ID="$APP_TEAM_ID" \
CODEXBAR_SPARKLE_PUBLIC_ED_KEY="$CODEXBAR_SPARKLE_PUBLIC_ED_KEY" \
CODEXBAR_FEED_URL="${CODEXBAR_FEED_URL:-https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/appcast.xml}" \
CODEXBAR_AUTO_CHECKS=true \
ARCHES="${ARCHES_VALUE}" \
./Scripts/package_app.sh release
```

- [ ] **Step 5: Make `make_appcast.sh` fork-safe**

Set defaults from `CODEXBAR_RELEASE_REPO`:

```bash
RELEASE_REPO=${CODEXBAR_RELEASE_REPO:-steipete/CodexBar}
FEED_URL=${2:-"https://raw.githubusercontent.com/${RELEASE_REPO}/main/appcast.xml"}
DOWNLOAD_URL_PREFIX=${SPARKLE_DOWNLOAD_URL_PREFIX:-"https://github.com/${RELEASE_REPO}/releases/download/v${VERSION}/"}
```

Verify the appcast enclosure points to the Chinese release repo:

```bash
python3 - "$ROOT/appcast.xml" "$VERSION" "$RELEASE_REPO" <<'PY'
import sys, xml.etree.ElementTree as ET
appcast, version, repo = sys.argv[1:4]
root = ET.parse(appcast).getroot()
ns = {"sparkle": "http://www.andymatuschak.org/xml-namespaces/sparkle"}
for item in root.findall("./channel/item"):
    if item.findtext("sparkle:shortVersionString", namespaces=ns) == version:
        url = item.find("enclosure").get("url")
        if f"github.com/{repo}/releases/download/" not in url:
            raise SystemExit(f"wrong enclosure repo: {url}")
        break
else:
    raise SystemExit(f"missing appcast version {version}")
PY
```

- [ ] **Step 6: Create `Scripts/release_zh.sh`**

The script must run in this order:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT"

err() { echo "ERROR: $*" >&2; exit 1; }

git diff --quiet || err "Worktree has unstaged changes"
git diff --cached --quiet || err "Worktree has staged but uncommitted changes"

source "$ROOT/version.env"

: "${CODEXBAR_RELEASE_REPO:=zpmdd/CodexBar-zh}"
: "${CODEXBAR_FEED_URL:=https://raw.githubusercontent.com/${CODEXBAR_RELEASE_REPO}/main/appcast.xml}"
: "${APP_IDENTITY:?Set APP_IDENTITY}"
: "${APP_TEAM_ID:?Set APP_TEAM_ID}"
: "${CODEXBAR_SPARKLE_PUBLIC_ED_KEY:?Set CODEXBAR_SPARKLE_PUBLIC_ED_KEY}"
: "${SPARKLE_PRIVATE_KEY_FILE:?Set SPARKLE_PRIVATE_KEY_FILE}"
: "${APP_STORE_CONNECT_API_KEY_P8:?Set APP_STORE_CONNECT_API_KEY_P8}"
: "${APP_STORE_CONNECT_KEY_ID:?Set APP_STORE_CONNECT_KEY_ID}"
: "${APP_STORE_CONNECT_ISSUER_ID:?Set APP_STORE_CONNECT_ISSUER_ID}"

git fetch upstream --prune
python3 Scripts/audit_localization.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test \
  --filter 'CodexBarLocalizationTests|AppLanguagePreferenceTests|CodexBarWidgetProviderTests|CLICostTests|UsageStorePlanUtilizationDerivedChartTests'

CODEXBAR_RELEASE_REPO="$CODEXBAR_RELEASE_REPO" \
CODEXBAR_FEED_URL="$CODEXBAR_FEED_URL" \
APP_IDENTITY="$APP_IDENTITY" \
APP_TEAM_ID="$APP_TEAM_ID" \
CODEXBAR_SPARKLE_PUBLIC_ED_KEY="$CODEXBAR_SPARKLE_PUBLIC_ED_KEY" \
./Scripts/sign-and-notarize.sh

gh release create "v${MARKETING_VERSION}" "CodexBar-${MARKETING_VERSION}.zip" \
  --repo "$CODEXBAR_RELEASE_REPO" \
  --title "CodexBar ${MARKETING_VERSION}" \
  --notes-file "dist/RELEASE_NOTES.md"

CODEXBAR_RELEASE_REPO="$CODEXBAR_RELEASE_REPO" \
SPARKLE_PRIVATE_KEY_FILE="$SPARKLE_PRIVATE_KEY_FILE" \
./Scripts/make_appcast.sh "CodexBar-${MARKETING_VERSION}.zip" "$CODEXBAR_FEED_URL"

SPARKLE_PRIVATE_KEY_FILE="$SPARKLE_PRIVATE_KEY_FILE" ./Scripts/verify_appcast.sh "$MARKETING_VERSION"

git add appcast.xml
git commit -m "Update Chinese appcast for ${MARKETING_VERSION}"
git push origin HEAD:main
```

- [ ] **Step 7: Add updater availability tests**

Create `Tests/CodexBarTests/UpdaterAvailabilityTests.swift` around a pure helper extracted from `makeUpdaterController()`:

```swift
struct UpdaterAvailabilityDecision: Equatable {
    let isAvailable: Bool
    let reason: String?
}
```

Expected tests:

```swift
#expect(UpdaterAvailabilityDecision.evaluate(isBundledApp: false, isHomebrew: false, isDeveloperIDSigned: true).isAvailable == false)
#expect(UpdaterAvailabilityDecision.evaluate(isBundledApp: true, isHomebrew: true, isDeveloperIDSigned: true).reason?.contains("Homebrew") == true)
#expect(UpdaterAvailabilityDecision.evaluate(isBundledApp: true, isHomebrew: false, isDeveloperIDSigned: false).isAvailable == false)
#expect(UpdaterAvailabilityDecision.evaluate(isBundledApp: true, isHomebrew: false, isDeveloperIDSigned: true).isAvailable == true)
```

- [ ] **Step 8: Verify a real signed update**

From a previous signed Chinese release installed in `/Applications/CodexBar.app`:

```bash
codesign --verify --deep --strict --verbose=4 /Applications/CodexBar.app
spctl -a -t exec -vv /Applications/CodexBar.app
plutil -p /Applications/CodexBar.app/Contents/Info.plist | grep -E 'SUFeedURL|SUPublicEDKey|SUEnableAutomaticChecks'
```

Expected:

- `SUFeedURL` is the Chinese appcast URL.
- `SUPublicEDKey` is the Chinese release public key.
- `SUEnableAutomaticChecks` is `true`.
- About page shows update controls, not unavailable text.

Manual live test:

```bash
RUN_SPARKLE_UPDATE_TEST=1 ./Scripts/test_live_update.sh "v<previous-version>" "v<new-version>"
```

Expected: Sparkle downloads and installs the new Chinese release, the app relaunches as `CodexBar`, and the language setting plus Chinese UI remain intact.

## Task 4: Safe Upstream Adaptation Before Every Automatic Update

**Files:**
- Create: `Scripts/audit_localization.py`
- Modify: `docs/LOCALIZATION.zh.md`
- Modify: `docs/RELEASING.zh.md`

- [ ] **Step 1: Require upstream sync before releasing**

Add this mandatory pre-release sequence to `docs/RELEASING.zh.md`:

```bash
git status --short
git fetch upstream --prune
git rebase upstream/main
python3 Scripts/audit_localization.py
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test \
  --filter 'CodexBarLocalizationTests|AppLanguagePreferenceTests|CodexBarWidgetProviderTests|CLICostTests'
```

- [ ] **Step 2: Define fallback rules**

Add:

```markdown
### 上游新增功能的显示规则

- 旧英文 key 仍存在：继续显示已有中文。
- 上游新增英文 key：先显示英文原文，审计脚本报告缺失翻译。
- 上游改写英文 key：旧翻译不强行套用，新英文原文显示，等待人工补译。
- 上游删除功能：对应翻译可暂留 catalog，不影响运行。
- 动态文案匹配不到：显示上游英文原文。
```

- [ ] **Step 3: Add release blocking rules**

Release must stop if:

```text
swift build fails
required localization tests fail
Sparkle appcast signature verification fails
zip URL returns non-200
About page still reports updater unavailable in a Developer ID signed release
```

Release may continue if:

```text
audit reports new untranslated upstream strings
those strings safely display English原文
```

## Task 5: Final Verification Checklist

**Files:**
- No source files expected.

- [ ] **Step 1: Localization test**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer swift test \
  --filter 'CodexBarLocalizationTests|UsageStorePlanUtilizationDerivedChartTests'
```

- [ ] **Step 2: Build and restart current local app**

```bash
DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer ./Scripts/compile_and_run.sh
```

- [ ] **Step 3: Manual UI check**

Verify:

- `订阅使用率` submenu shows `会话` and `每周`.
- Detail line does not show `May ... used`; it shows Chinese date and `已用`.
- `费用` submenu empty selection shows `悬停柱形查看详情`.
- About page on adhoc local builds clearly says automatic updates require signed GitHub release.
- About page on signed release builds shows normal Sparkle controls.

- [ ] **Step 4: Release update check**

After publishing a signed release:

```bash
curl -I "https://raw.githubusercontent.com/zpmdd/CodexBar-zh/main/appcast.xml"
SPARKLE_PRIVATE_KEY_FILE="$SPARKLE_PRIVATE_KEY_FILE" ./Scripts/verify_appcast.sh "$MARKETING_VERSION"
```

Expected:

- appcast URL returns `200`.
- enclosure URL points to `zpmdd/CodexBar-zh`.
- Sparkle signature verifies.
- Previous signed Chinese release updates to the new signed Chinese release.

## Practical Consequence For The Current Installed Build

The current locally installed build is adhoc signed and has Sparkle disabled in `Info.plist`. It cannot update itself into the first signed build. The first Sparkle-enabled Chinese release must be installed once manually. After that, future releases can update automatically from the Chinese appcast.

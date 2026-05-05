import CodexBarCore
import Foundation

extension CodexBarCLI {
    static func usageHelp(version: String) -> String {
        if CLIL10n.usesChinese {
            return """
            CodexBar \(version)

            用法:
              codexbar usage [--format text|json] [--provider \(ProviderHelp.list)] [--status]

            说明:
              以文本（默认）或 JSON 输出已启用服务的用量。命令名、参数名和 JSON 字段保持英文，便于脚本调用。
              Codex 默认读取 OpenAI Web Dashboard；Claude 默认读取 claude.ai API；Kilo 默认读取 app.kilo.ai API。
              token 账户从 ~/.codexbar/config.json 读取。

            全局参数:
              -h, --help      显示帮助
              -V, --version   显示版本
              -v, --verbose   启用详细日志
              --no-color      禁用 ANSI 颜色
              --json-output   将机器可读日志输出到 stderr

            示例:
              codexbar usage
              codexbar usage --provider claude
              codexbar usage --format json --provider all --pretty
              codexbar usage --status
            """
        }

        return """
        CodexBar \(version)

        Usage:
          codexbar usage [--format text|json]
                       [--json]
                       [--json-only]
                       [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                       [--provider \(ProviderHelp.list)]
                       [--account <label>] [--account-index <index>] [--all-accounts]
                       [--no-credits] [--no-color] [--pretty] [--status] [--source <auto|web|cli|oauth|api>]
                       [--web-timeout <seconds>] [--web-debug-dump-html] [--antigravity-plan-debug] [--augment-debug]

        Description:
          Print usage from enabled providers as text (default) or JSON. Honors your in-app toggles.
          Output format: use --json (or --format json) for JSON on stdout; use --json-output for JSON logs on stderr.
          Source behavior is provider-specific:
          - Codex: OpenAI web dashboard (usage limits, credits remaining, code review remaining, usage breakdown).
            Auto falls back to Codex CLI only when cookies are missing.
          - Claude: claude.ai API.
            Auto falls back to Claude CLI only when cookies are missing.
          - Kilo: app.kilo.ai API.
            Auto falls back to Kilo CLI when API credentials are missing or unauthorized.
          Token accounts are loaded from ~/.codexbar/config.json.
          Use --account or --account-index to select a specific token account, or --all-accounts to fetch all.
          Account selection requires a single provider.

        Global flags:
          -h, --help      Show help
          -V, --version   Show version
          -v, --verbose   Enable verbose logging
          --no-color      Disable ANSI colors in text output
          --log-level <trace|verbose|debug|info|warning|error|critical>
          --json-output   Emit machine-readable logs (JSONL) to stderr

        Examples:
          codexbar usage
          codexbar usage --provider claude
          codexbar usage --provider gemini
          codexbar usage --format json --provider all --pretty
          codexbar usage --provider all --json
          codexbar usage --status
          codexbar usage --provider codex --source web --format json --pretty
        """
    }

    static func costHelp(version: String) -> String {
        if CLIL10n.usesChinese {
            return """
            CodexBar \(version)

            用法:
              codexbar cost [--format text|json] [--provider \(ProviderHelp.list)] [--refresh]

            说明:
              从 Claude/Codex 本地日志和支持的 pi sessions 输出 token 费用用量。
              该命令不需要 Web 或 CLI 登录，默认使用缓存扫描结果，传入 --refresh 可强制刷新。

            示例:
              codexbar cost
              codexbar cost --provider claude --format json --pretty
            """
        }

        return """
        CodexBar \(version)

        Usage:
          codexbar cost [--format text|json]
                       [--json]
                       [--json-only]
                       [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                       [--provider \(ProviderHelp.list)]
                       [--no-color] [--pretty] [--refresh]

        Description:
          Print local token cost usage from Claude/Codex native logs plus supported pi sessions.
          This does not require web or CLI access and uses cached scan results unless --refresh is provided.

        Examples:
          codexbar cost
          codexbar cost --provider claude --format json --pretty
        """
    }

    static func configHelp(version: String) -> String {
        if CLIL10n.usesChinese {
            return """
            CodexBar \(version)

            用法:
              codexbar config validate [--format text|json]
              codexbar config dump [--format text|json]

            说明:
              验证或输出 CodexBar 配置文件。默认子命令是 validate。

            示例:
              codexbar config validate --format json --pretty
              codexbar config dump --pretty
            """
        }

        return """
        CodexBar \(version)

        Usage:
          codexbar config validate [--format text|json]
                                 [--json]
                                 [--json-only]
                                 [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                                 [-v|--verbose]
                                 [--pretty]
          codexbar config dump [--format text|json]
                             [--json]
                             [--json-only]
                             [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                             [-v|--verbose]
                             [--pretty]

        Description:
          Validate or print the CodexBar config file (default: validate).

        Examples:
          codexbar config validate --format json --pretty
          codexbar config dump --pretty
        """
    }

    static func rootHelp(version: String) -> String {
        if CLIL10n.usesChinese {
            return """
            CodexBar \(version)

            用法:
              codexbar [usage 参数]
              codexbar usage [--format text|json] [--provider \(ProviderHelp.list)]
              codexbar cost [--format text|json] [--provider \(ProviderHelp.list)]
              codexbar config <validate|dump> [--format text|json]

            全局参数:
              -h, --help      显示帮助
              -V, --version   显示版本
              -v, --verbose   启用详细日志
              --no-color      禁用 ANSI 颜色
              --json-output   将机器可读日志输出到 stderr

            示例:
              codexbar
              codexbar --format json --provider all --pretty
              codexbar cost --provider claude --format json --pretty
              codexbar config validate --format json --pretty
            """
        }

        return """
        CodexBar \(version)

        Usage:
          codexbar [--format text|json]
                  [--json]
                  [--json-only]
                  [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                  [--provider \(ProviderHelp.list)]
                  [--account <label>] [--account-index <index>] [--all-accounts]
                  [--no-credits] [--no-color] [--pretty] [--status] [--source <auto|web|cli|oauth|api>]
                  [--web-timeout <seconds>] [--web-debug-dump-html] [--antigravity-plan-debug] [--augment-debug]
          codexbar cost [--format text|json]
                       [--json]
                       [--json-only]
                       [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>] [-v|--verbose]
                       [--provider \(ProviderHelp.list)] [--no-color] [--pretty] [--refresh]
          codexbar config <validate|dump> [--format text|json]
                                        [--json]
                                        [--json-only]
                                        [--json-output] [--log-level <trace|verbose|debug|info|warning|error|critical>]
                                        [-v|--verbose]
                                        [--pretty]

        Global flags:
          -h, --help      Show help
          -V, --version   Show version
          -v, --verbose   Enable verbose logging
          --no-color      Disable ANSI colors in text output
          --log-level <trace|verbose|debug|info|warning|error|critical>
          --json-output   Emit machine-readable logs (JSONL) to stderr

        Examples:
          codexbar
          codexbar --format json --provider all --pretty
          codexbar --provider all --json
          codexbar --provider gemini
          codexbar cost --provider claude --format json --pretty
          codexbar config validate --format json --pretty
        """
    }
}

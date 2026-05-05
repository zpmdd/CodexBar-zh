import CodexBarCore
import Foundation

@MainActor
final class CodexProviderRuntime: ProviderRuntime {
    let id: UsageProvider = .codex

    func perform(action: ProviderRuntimeAction, context: ProviderRuntimeContext) async {
        switch action {
        case let .openAIWebAccessToggled(enabled):
            if enabled {
                await context.store.refreshOpenAIDashboardIfNeeded(force: true, bypassCoalescing: true)
            } else {
                context.store.resetOpenAIWebState()
            }
        case .forceSessionRefresh:
            break
        }
    }
}

import Foundation
import Combine
#if canImport(WidgetKit)
import WidgetKit
#endif

class ContextViewModel: ObservableObject {
    @Published var activeSnapshot: ContextSnapshot? = nil
    @Published var totalLocksCompleted: Int = 0

    init() {
        migrateLegacyCacheIfNeeded()
        self.activeSnapshot = AppGroupStore.loadSnapshot()
        self.totalLocksCompleted = AppGroupStore.loadTotalLocks()
    }

    func cacheCurrentContext(text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }

        let newSnapshot = ContextSnapshot(thoughtText: cleanText, timestamp: Date(), isActive: true)
        self.activeSnapshot = newSnapshot

        AppGroupStore.saveSnapshot(newSnapshot)
        reloadHomeScreenWidget()
    }

    func clearAndResume() {
        self.activeSnapshot = nil
        self.totalLocksCompleted += 1

        AppGroupStore.clearSnapshot(totalLocks: totalLocksCompleted)
        reloadHomeScreenWidget()
    }

    private func migrateLegacyCacheIfNeeded() {
        guard AppGroupStore.loadSnapshot() == nil,
              let data = UserDefaults.standard.data(forKey: AppGroupStore.storageKey),
              let decoded = try? JSONDecoder().decode(ContextSnapshot.self, from: data) else {
            return
        }
        AppGroupStore.saveSnapshot(decoded)
    }

    private func reloadHomeScreenWidget() {
        #if canImport(WidgetKit)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}

import Foundation

enum AppGroupStore {
    static let suiteName = "group.app.contextlock.ContextLock"
    static let storageKey = "ContextLock_ActiveCache"
    static let statsKey = "ContextLock_TotalCount"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static func loadSnapshot() -> ContextSnapshot? {
        guard let data = defaults.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(ContextSnapshot.self, from: data)
    }

    static func loadTotalLocks() -> Int {
        defaults.integer(forKey: statsKey)
    }

    static func saveSnapshot(_ snapshot: ContextSnapshot) {
        if let encoded = try? JSONEncoder().encode(snapshot) {
            defaults.set(encoded, forKey: storageKey)
            defaults.synchronize()
        }
    }

    static func clearSnapshot(totalLocks: Int) {
        defaults.removeObject(forKey: storageKey)
        defaults.set(totalLocks, forKey: statsKey)
        defaults.synchronize()
    }
}

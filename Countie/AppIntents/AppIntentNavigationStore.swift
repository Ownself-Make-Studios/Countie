import Foundation

enum AppIntentNavigationStore {
    private static let suiteName = "group.com.nabilridhwan.countie"
    private static let pendingCountdownIDKey = "appIntent.pendingCountdownID"

    static func requestOpenCountdown(id: String) {
        defaults.set(id, forKey: pendingCountdownIDKey)
    }

    static func consumePendingCountdownID() -> UUID? {
        guard let idString = defaults.string(forKey: pendingCountdownIDKey) else {
            return nil
        }

        defaults.removeObject(forKey: pendingCountdownIDKey)
        return UUID(uuidString: idString)
    }

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
}

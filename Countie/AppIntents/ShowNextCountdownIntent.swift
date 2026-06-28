import AppIntents
import Foundation
import SwiftData

public struct ShowNextCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Show Next Countdown"
    public static var description = IntentDescription("Shows your next upcoming countdown.")

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let item = nextCountdown() else {
            return .result(dialog: "You don't have any upcoming countdowns.")
        }

        let remainingText = Self.remainingText(until: item.date)
        return .result(dialog: "Your next countdown is \(item.name), \(remainingText).")
    }

    @MainActor
    private func nextCountdown() -> CountdownItem? {
        let context = CountieModelContainer.sharedModelContainer.mainContext
        let descriptor = CountdownItem.upcomingDescriptor(limit: 1)
        return try? context.fetch(descriptor).first
    }

    private static func remainingText(until date: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2

        guard let text = formatter.string(from: Date.now, to: date) else {
            return "coming up soon"
        }

        return "in \(text)"
    }
}

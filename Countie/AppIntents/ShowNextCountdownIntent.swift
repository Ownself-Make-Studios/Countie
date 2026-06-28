import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct NoUpcomingCountdownError: LocalizedError {
    var errorDescription: String? {
        "You don't have any upcoming countdowns."
    }
}

public struct ShowNextCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Show Next Countdown"
    public static var description = IntentDescription("Shows your next upcoming countdown.")

    public init() {}

    @MainActor
    public func perform() async throws -> some ReturnsValue<CountdownEntity> & ProvidesDialog & ShowsSnippetView {
        guard let item = nextCountdown() else {
            throw NoUpcomingCountdownError()
        }

        let remainingText = Self.remainingText(item: item)
        let entity = CountdownEntity(item: item)
        
        return .result(
            value: entity,
            dialog: "Your next countdown is \(item.name), \(remainingText).",
            view: CountdownRow(item: item)
                .padding()
                .background(.backgroundThemeRespectable, in: RoundedRectangle(cornerRadius: 10))
                .padding()
        )
    }

    @MainActor
    private func nextCountdown() -> CountdownItem? {
        let context = CountieModelContainer.sharedModelContainer.mainContext
        let descriptor = CountdownItem.upcomingDescriptor(limit: 1)
        return try? context.fetch(descriptor).first
    }

    private static func remainingText(item: CountdownItem) -> String {
        return "in approximately \(item.getTimeRemainingFn())"
    }
}

import AppIntents
import Foundation
import SwiftData
import SwiftUI

struct NoUpcomingCountdownError: LocalizedError {
    var errorDescription: String? {
        String(localized: "You don't have any upcoming countdowns.")
    }
}

@available(iOS 27.3, *)
@AppIntent(.tool)
public struct ShowNextCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Show Next Countdown"
    public static var description = IntentDescription("Shows your next upcoming countdown.")

    public init() {}

    @MainActor
    public func perform() async throws -> some ReturnsValue<CountdownEntity> {
        guard let item = nextCountdown() else {
            throw NoUpcomingCountdownError()
        }

//        let remainingText = Self.remainingText(item: item)
        let entity = CountdownEntity(item: item)
        
        return .result(
            value: entity,
        )
    }

    @MainActor
    private func nextCountdown() -> CountdownItem? {
        let context = CountieModelContainer.sharedModelContainer.mainContext
        let descriptor = CountdownItem.upcomingDescriptor(limit: 1)
        return try? context.fetch(descriptor).first
    }

//    private static func remainingText(item: CountdownItem) -> String {
//        String(
//            localized: "in approximately \(item.getTimeRemainingFn())",
//            comment: "Approximate time remaining before the next countdown ends."
//        )
//    }
}

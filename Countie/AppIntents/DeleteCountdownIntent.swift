import AppIntents
import Foundation
import SwiftData
import WidgetKit

public struct DeleteCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Delete Countdown"
    public static var description = IntentDescription("Deletes a countdown from Countie.")

    @Parameter(title: "Countdown")
    public var countdown: CountdownEntity

    public static var parameterSummary: some ParameterSummary {
        Summary("Delete \(\.$countdown)")
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let uuid = UUID(uuidString: countdown.id) else {
            throw $countdown.needsValueError("Choose a countdown to delete.")
        }

        let context = CountieModelContainer.sharedModelContainer.mainContext
        let descriptor = CountdownItem.activeDescriptor(id: uuid)

        guard let item = try context.fetch(descriptor).first else {
            return .result(dialog: "I couldn't find \(countdown.name).")
        }

        item.isDeleted = true
        try context.save()

        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Deleted \(countdown.name).")
    }
}

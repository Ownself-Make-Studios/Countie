//
//  CreateCountdownIntent.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/26.
//

import Foundation
import AppIntents
import SwiftData
import WidgetKit

public struct CreateCountdownIntent: AppIntent {
    public static var title: LocalizedStringResource = "Create Countdown"
    public static var description = IntentDescription("Creates a new countdown in Countie.")

    @Parameter(
        title: "Countdown Name",
        requestValueDialog: "What is the countdown for?"
    )
    public var name: String

    @Parameter(
        title: "Countdown Date",
        requestValueDialog: "When is it?"
    )
    public var date: Date

    @Parameter(title: "Include Time", default: true)
    public var includeTime: Bool

    public static var parameterSummary: some ParameterSummary {
        Summary("Create \(\.$name) for \(\.$date)")
    }

    public init() {}

    @MainActor
    public func perform() async throws -> some IntentResult & ProvidesDialog {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw $name.needsValueError("What should the countdown be called?")
        }

        let normalizedDate = includeTime
            ? date
            : Calendar.current.startOfDay(for: date)

        let item = CountdownItem(
            name: trimmedName,
            includeTime: includeTime,
            date: normalizedDate,
            iconName: CountdownEventIcon.default,
            colorNameRaw: CountdownEventColor.blue.rawValue
        )

        let context = NomaModelContainer.sharedModelContainer.mainContext
        context.insert(item)
        try context.save()

        WidgetCenter.shared.reloadAllTimelines()

        return .result(dialog: "Created \(trimmedName).")
    }
}

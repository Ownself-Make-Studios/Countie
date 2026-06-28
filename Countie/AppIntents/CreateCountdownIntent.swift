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
import CoreSpotlight

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

        let item = CountdownItem(
            name: trimmedName,
            date: date,
            iconName: CountdownEventIcon.default,
            color: .blue
        )

        let context = CountieModelContainer.sharedModelContainer.mainContext
        context.insert(item)
        try context.save()
        
        try? await CSSearchableIndex.default().indexAppEntities([
            CountdownEntity(item: item)
        ])

        WidgetCenter.shared.reloadAllTimelines()
        CountieShortcuts.updateAppShortcutParameters()

        return .result(dialog: "Created \(trimmedName).")
    }
}

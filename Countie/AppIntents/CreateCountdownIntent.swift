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

@available(iOS 27.3, *)
@AppIntent(.tool)
struct CreateCountdownIntent: AppIntent {
    // Empty init
    public init(){}
    
    static let title: LocalizedStringResource = "Create Countdown"
    static let description = IntentDescription("Creates a new countdown")

    @Parameter(
        title: "Name",
        description: LocalizedStringResource("The name of the countdown"),
        requestValueDialog: "What is the countdown for?"
    )
    var name: String

    @Parameter(
        title: "Countdown Date",
        description: LocalizedStringResource("When is the countdown for?"),
        requestValueDialog: "When is it?"
    )
    var date: Date

    public static var parameterSummary: some ParameterSummary {
        Summary("Create \(\.$name) for \(\.$date)")
    }

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<CountdownEntity>{
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw $name.needsValueError("What should the countdown be called?")
        }
        
        let randomColor = CountdownEventColor.allCases.randomElement()!

        let item = CountdownItem(
            name: trimmedName,
            date: date,
            iconName: CountdownEventIcon.default,
            color: randomColor
        )

        let context = CountieModelContainer.sharedModelContainer.mainContext
        context.insert(item)
        try context.save()
        
        CountdownSearchIndex.index(item)
        WidgetCenter.shared.reloadAllTimelines()
        CountieShortcuts.updateAppShortcutParameters()

        return .result(value: CountdownEntity(item: item))
    }
}

//
//  AppIntent.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import AppIntents
import SwiftData

struct CountdownSelection: AppEntity, Identifiable, Hashable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = TypeDisplayRepresentation(name: LocalizedStringResource("Countdown"))
    static var defaultQuery = CountdownQuery()
    
    let id: String
    let name: String
    let date: Date
    
    // What shows up when the menu is displayed
    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: .init(stringLiteral: name),
            subtitle: .init(stringLiteral: date.formatted())
        )
    }
    
    init(item: CountdownItem) {
        self.id = item.id.uuidString
        self.name = item.name
        self.date = item.date
    }
}

struct CountdownQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CountdownSelection] {
        let items = await fetchCountdownItems()
        return items.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [CountdownSelection] {
        var items = await fetchCountdownItems()
        items.sort { $0.date < $1.date }
        return items
    }
    
    @MainActor
    func fetchCountdownItems() async -> [CountdownSelection] {
        let now = Date()
        
        let modelContainer = NomaModelContainer.sharedModelContainer
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { $0.isDeleted == false && $0.date >= now},
            sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)]
            
        )
        let items = (try? modelContainer.mainContext.fetch(descriptor)) ?? []
        return items.map { CountdownSelection(item: $0) }
        
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Countdown Widget" }
    static var description: IntentDescription { "Access your countdowns from this widget!" }
    
    @Parameter(title: "Display Only Selected Countdown", default: false)
    var showSpecificCountdown: Bool?
    
    @Parameter(title: "Show Countdown Progress Bar", default: true)
    var showProgress: Bool?
    
    @Parameter(title: "Select Countdown to Display")
    var countdown: CountdownSelection?
    
    // Read "ParameterSummary"
    // https://developer.apple.com/documentation/appintents/widgetconfigurationintent
    static var parameterSummary: some ParameterSummary {
        When(\ConfigurationAppIntent.$showSpecificCountdown, .equalTo, true) {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
                \.$countdown
            }
        } otherwise: {
            Summary {
                \.$showProgress
                \.$showSpecificCountdown
            }
        }
    }
}

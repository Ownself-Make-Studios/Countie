//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        let countdownItem: CountdownItem = .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: .now.addingTimeInterval(60 * 60 * 24 * 3))
        
        countdownItem.countSince = Date.now.addingTimeInterval(60 * 60 * 24 * 2) // 2 days ago
        
        return SimpleEntry(
            date: Date(),
            countdownItem: countdownItem,
            showProgress: true
        )
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        
        var countdownItem: CountdownItem? = await getLatestActiveCountdown()
        
        if countdownItem == nil {
            countdownItem = .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: .now.addingTimeInterval(60 * 60 * 24 * 3))
        }
        
        return SimpleEntry(
            date: Date(),
            countdownItem: countdownItem,
            showProgress: configuration.showProgress ?? true
        )
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        var countdownItem: CountdownItem?
        
        if configuration.showSpecificCountdown == true {
            countdownItem = await getCountdownItem(by: configuration.countdown?.id ?? "")
        } else {
            // If no specific countdown is selected, get the latest active countdown
            countdownItem = await getLatestActiveCountdown()
        }
        
        
        print("Renewing Timeline")
        // If there is no countdowns, set it to refresh NEVER
        //        if(items.isEmpty){
        //            return Timeline(entries: [], policy: .never)
        //        }
        
        var entries: [SimpleEntry] = []
        
        if let item = countdownItem {
            
            var entry: SimpleEntry =  SimpleEntry(date: item.date, countdownItem: item, showProgress: configuration.showProgress ?? true)
            
            // Set relevance based on the first countdown date
            let timeInterval = abs(item.date.timeIntervalSince(.now))
            // The closer to now, the higher the score (1.0 at event time, approaches 0 as it gets further)
            let score = 1.0 / (1.0 + timeInterval / 3600.0) // decay per hour
            entry.relevance = TimelineEntryRelevance(score: Float(score), duration: item.date.timeIntervalSinceNow)
            
            
            entries = [
               entry
            ]
        }
        
        // Refresh every after 1 hour
        return Timeline(entries: entries, policy: .after(.now.addingTimeInterval(3600)))
    }
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
    
    static func predicate() -> Predicate<CountdownItem> {
        let now = Date()
        return #Predicate<CountdownItem> { $0.date >= now }
    }
    
    // Fetch a countdown by id
    @MainActor
    private func getCountdownItem(by id: String) -> CountdownItem? {
        let uuid: UUID = UUID(uuidString: id)!
        let modelContainer = NomaModelContainer.sharedModelContainer
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { $0.id == uuid && !$0.isDeleted },
            sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)]
        )
        let items = try? modelContainer.mainContext.fetch(descriptor)
        return items?.first
    }
    
    // Fetch the latest countdown that has not passed
    @MainActor
    private func getLatestActiveCountdown() -> CountdownItem? {
        let modelContainer = NomaModelContainer.sharedModelContainer
        let now = Date()
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { $0.date >= now && !$0.isDeleted },
            sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)]
        )
        let items = try? modelContainer.mainContext.fetch(descriptor)
        return items?.first
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let countdownItem: CountdownItem?
    let showProgress: Bool
    var relevance: TimelineEntryRelevance? = nil
}

struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(
                    .fill.tertiary,
                    for: .widget
                )
                .modelContainer(
                    NomaModelContainer.sharedModelContainer
                )
        }
        .configurationDisplayName("Countdown Widget")
        .description("Keep track of your countdowns with this widget!")
        .supportedFamilies(
            [
                .accessoryCircular,
                .accessoryInline,
                .accessoryRectangular,
                .systemSmall,
                .systemMedium,
            ])
    }
}

#Preview(as: .accessoryRectangular) {
    CountdownWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        countdownItem: .SampleFutureTimer,
        showProgress: true
    )
    
    
}

//
//  MultipleCountdownWidget.swift
//  MultipleCountdownWidget
//
//  Created by Nabil Ridhwan on 25/6/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            countdowns: [
                .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
                .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
                .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
                .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
                
            ]
        )
    }
    
    func snapshot(for configuration: MultipleCountdownConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(
            date: Date(),
            countdowns: [
                .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
                .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
                .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
                .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
            ]
        )
    }
    
    func timeline(for configuration: MultipleCountdownConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        var entries: [SimpleEntry] = []
        
        let countdowns = await getLatestCountdowns()
        let now = Date()
        
        if let safeCountdowns = countdowns {
            var entry =
            SimpleEntry(
                date: Date(),
                countdowns: safeCountdowns
            )
            
            // Set relevance based on the first countdown date
            if let firstCountdown = safeCountdowns.first {
                let timeInterval = abs(firstCountdown.date.timeIntervalSince(now))
                // The closer to now, the higher the score (1.0 at event time, approaches 0 as it gets further)
                let score = 1.0 / (1.0 + timeInterval / 3600.0) // decay per hour
                entry.relevance = TimelineEntryRelevance(score: Float(score), duration: firstCountdown.date.timeIntervalSinceNow)
            }
            
            entries.append(entry)
        }else{
            return Timeline(entries: entries, policy: .never)
        }
        
        return Timeline(entries: entries, policy: .after(Date().addingTimeInterval(60 * 60 * 1))) // Refresh every 1 hour
    }
    
    // Fetch latest active countdowns
    @MainActor
    private func getLatestCountdowns(count: Int = 4) -> [CountdownItem]? {
        
        let modelContainer = NomaModelContainer.sharedModelContainer
        
        let now = Date()
        
        var descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { $0.date >= now && $0.isDeleted == false },
            sortBy: [SortDescriptor(\CountdownItem.date, order: .forward)],
        )
        
        descriptor.fetchLimit = count
        
        do {
            let items = try modelContainer.mainContext.fetch(descriptor)
            print(items.count)
            return items
        }catch {
            print("Error fetching countdowns: \(error)")
            return nil
        }
    }
    
    
    //    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
    //        // Generate a list containing the contexts this widget is relevant in.
    //    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let countdowns: [CountdownItem]
    var relevance: TimelineEntryRelevance? = nil
}

struct MultipleCountdownWidget: Widget {
    let kind: String = "MultipleCountdownWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MultipleCountdownConfigurationAppIntent.self, provider: Provider()) { entry in
            MultipleCountdownWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .modelContainer(NomaModelContainer.sharedModelContainer)
            
            
            
        }
        .contentMarginsDisabled()
        .configurationDisplayName("Multiple Countdowns")
        .description("Keep track of 4 of your upcoming countdowns!")
        .supportedFamilies(
            [
                .systemSmall,
                .systemMedium,
            ])
    }
}

#Preview(as: .systemSmall) {
    MultipleCountdownWidget()
} timeline: {
    SimpleEntry(
        date:.now,
        countdowns: [
            .init(emoji: "🎉", name: "Welcome to Countie!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 3)),
            .init(emoji: "🎂", name: "My Birthday", includeTime: true, date: Date().addingTimeInterval(60 * 60 * 24 * 5)),
            .init(emoji: "🎈", name: "Party Time!", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 7)),
            .init(emoji: "🎊", name: "New Year Celebration", includeTime: false, date: Date().addingTimeInterval(60 * 60 * 24 * 10))
        ]
    )
}

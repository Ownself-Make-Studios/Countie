//
//  CountdownStore.swift
//  Countie
//
//  Created by Nabil Ridhwan on 17/8/25.
//

internal import Combine
import EventKit
import SwiftData
import SwiftUI
import WidgetKit
import AppIntents
import AppIntents

class CountdownStore: ObservableObject {
    private var eventStore = EKEventStore()
    private var cancellables: [NSObjectProtocol] = []

    @Published var countdowns: [CountdownItem] = []
    @Published var upcomingCountdowns: [CountdownItem] = []
    @Published var passedCountdowns: [CountdownItem] = []

    private var context: ModelContext

    func syncCountdownsWithEvents() {
        if let countdowns = self.fetchCalendarLinkedCountdowns() {
            for countdown in countdowns {
                if let event = CalendarAccessManager.resolveEvent(for: countdown) {
                    // Update countdown date to match event's start date
                    if countdown.date != event.startDate {
                        countdown.date = event.startDate
                    }

                    let linkDetails = CalendarEventLinkDetails(event: event)
                    if countdown.calendarEventIdentifier != linkDetails.eventIdentifier {
                        countdown.calendarEventIdentifier = linkDetails.eventIdentifier
                    }
                    if countdown.calendarSeriesIdentifier != linkDetails.seriesIdentifier {
                        countdown.calendarSeriesIdentifier = linkDetails.seriesIdentifier
                    }
                    if countdown.calendarOccurrenceDate != linkDetails.occurrenceDate {
                        countdown.calendarOccurrenceDate = linkDetails.occurrenceDate
                    }
                    if countdown.calendarRecurrenceImportScope != linkDetails.importScope {
                        countdown.calendarRecurrenceImportScope = linkDetails.importScope
                    }
                } else {
                    // Event was deleted or not found, mark countdown as deleted
                    countdown.isDeleted = true
                }
            }
            // Persist changes to the model context
            try? self.context.save()
            // Refresh countdown arrays and UI
            self.fetchCountdowns()
        }
    }

    init(context: ModelContext) {
        self.context = context
        fetchCountdowns()
        syncCountdownsWithEvents() // Sync at launch

        let token = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: self.eventStore,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.syncCountdownsWithEvents()
            WidgetCenter.shared.reloadAllTimelines()
            CountieShortcuts.updateAppShortcutParameters()
        }
        cancellables.append(token)
    }

    deinit {
        for token in cancellables {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func fetchCalendarLinkedCountdowns() -> [CountdownItem]? {
        try? context.fetch(CountdownItem.calendarLinkedUpcomingDescriptor())
    }

    func fetchCountdowns() {
        print("Fetching countdowns...")
        let fetchedItems = try? context.fetch(CountdownItem.activeDescriptor())

        countdowns = fetchedItems ?? []
        upcomingCountdowns = countdowns.filter { $0.date >= Date() }
        passedCountdowns = countdowns.filter { $0.date < Date() }

        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func fetchDeletedCountdowns() -> [CountdownItem]? {
        print("Fetching countdowns...")
        return (try? context.fetch(CountdownItem.deletedDescriptor())) ?? []
    }

    func deleteCountdown(_ countdown: CountdownItem) {
        let id = countdown.id
        
        countdown.isDeleted = true
        try? context.save()

        CountdownSearchIndex.delete(id: id)
        CountieShortcuts.updateAppShortcutParameters()
        fetchCountdowns()
    }
}

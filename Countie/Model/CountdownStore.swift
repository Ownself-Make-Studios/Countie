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

class CountdownStore: ObservableObject {
    private var eventStore = EKEventStore()
    private var cancellables: [NSObjectProtocol] = []

    @Published var countdowns: [CountdownItem] = []
    @Published var upcomingCountdowns: [CountdownItem] = []
    @Published var passedCountdowns: [CountdownItem] = []

    private var context: ModelContext

    private func normalizeAppearanceForAllCountdowns() {
        let descriptor = FetchDescriptor<CountdownItem>()
        guard let items = try? context.fetch(descriptor) else { return }

        let didChange = items.reduce(false) { partialResult, item in
            item.normalizeAppearance() || partialResult
        }

        if didChange {
            try? context.save()
        }
    }

    func syncCountdownsWithEvents() {
        var changedCountdowns: [CountdownItem] = []
        var deletedCountdownIDs: [UUID] = []

        if let countdowns = self.fetchCalendarLinkedCountdowns() {
            for countdown in countdowns {
                if let event = CalendarAccessManager.resolveEvent(for: countdown) {
                    // Update countdown date to match event's start date
                    if countdown.date != event.startDate {
                        countdown.date = event.startDate
                        changedCountdowns.append(countdown)
                    }

                    let linkDetails = CalendarEventLinkDetails(event: event)
                    if countdown.calendarEventIdentifier != linkDetails.eventIdentifier {
                        countdown.calendarEventIdentifier = linkDetails.eventIdentifier
                        if !changedCountdowns.contains(where: { $0.id == countdown.id }) {
                            changedCountdowns.append(countdown)
                        }
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
                    deletedCountdownIDs.append(countdown.id)
                }
            }
            // Persist changes to the model context
            try? self.context.save()
            // Refresh countdown arrays and UI
            self.fetchCountdowns()

            let changedSnapshots = changedCountdowns.map {
                (
                    id: $0.id,
                    name: $0.name,
                    date: $0.date,
                    reminders: CountdownReminderScheduler.snapshot(for: $0)
                )
            }

            Task {
                for countdownID in deletedCountdownIDs {
                    await CountdownReminderScheduler.removeNotifications(for: countdownID)
                }

                for countdown in changedSnapshots {
                    await CountdownReminderScheduler.syncNotifications(
                        countdownID: countdown.id,
                        countdownName: countdown.name,
                        eventDate: countdown.date,
                        reminders: countdown.reminders
                    )
                }
            }
        }
    }

    init(context: ModelContext) {
        self.context = context
        normalizeAppearanceForAllCountdowns()
        fetchCountdowns()
        syncCountdownsWithEvents() // Sync at launch
        let countdownSnapshots = self.countdowns
            .filter { !$0.isDeleted }
            .map {
                (
                    id: $0.id,
                    name: $0.name,
                    date: $0.date,
                    reminders: CountdownReminderScheduler.snapshot(for: $0)
                )
            }
        Task {
            for countdown in countdownSnapshots {
                await CountdownReminderScheduler.syncNotifications(
                    countdownID: countdown.id,
                    countdownName: countdown.name,
                    eventDate: countdown.date,
                    reminders: countdown.reminders
                )
            }
        }

        let token = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: self.eventStore,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.syncCountdownsWithEvents()
            WidgetCenter.shared.reloadAllTimelines()
        }
        cancellables.append(token)
    }

    deinit {
        for token in cancellables {
            NotificationCenter.default.removeObserver(token)
        }
    }

    func fetchCalendarLinkedCountdowns() -> [CountdownItem]? {
        let currentDate = Date()
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> {
                $0.isDeleted == false
                    && ($0.calendarEventIdentifier != nil || $0.calendarOccurrenceDate != nil)
                    && $0.date >= currentDate
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)

        return fetchedItems
    }

    func fetchCountdowns() {
        print("Fetching countdowns...")
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate { item in
                item.isDeleted == false
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)

        countdowns = fetchedItems ?? []
        let didNormalize = countdowns.reduce(false) { partialResult, item in
            item.normalizeAppearance() || partialResult
        }
        if didNormalize {
            try? context.save()
        }
        upcomingCountdowns = countdowns.filter { $0.date >= Date() }
        passedCountdowns = countdowns.filter { $0.date < Date() }

        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func fetchDeletedCountdowns() -> [CountdownItem]? {
        print("Fetching countdowns...")
        let descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate { item in
                item.isDeleted == true
            },
            sortBy: [
                SortDescriptor(\.date, order: .forward)
            ]
        )

        let fetchedItems = try? context.fetch(descriptor)
        return fetchedItems ?? []
    }

    func deleteCountdown(_ countdown: CountdownItem) {
        countdown.isDeleted = true
        try? context.save()
        let countdownID = countdown.id
        Task {
            await CountdownReminderScheduler.removeNotifications(for: countdownID)
        }
        fetchCountdowns()
    }
}

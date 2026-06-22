//
//  CountieTests.swift
//  CountieTests
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import Foundation
import SwiftData
import Testing
@testable import Countie

struct CountieTests {
    @Test func appearanceNormalizesInvalidValues() async throws {
        let appearance = CountdownAppearance(
            iconName: "not-a-symbol",
            colorRawValue: "not-a-color"
        )

        #expect(appearance.resolvedIconName == CountdownEventIcon.default)
        #expect(appearance.eventColor == .blue)
        #expect(appearance.normalized == .default)
    }

    @Test func appearanceRoundTripsThroughCodable() async throws {
        let appearance = CountdownAppearance(
            iconName: "sparkles",
            colorRawValue: CountdownEventColor.purple.rawValue
        )

        let data = try JSONEncoder().encode(appearance)
        let decoded = try JSONDecoder().decode(CountdownAppearance.self, from: data)

        #expect(decoded == appearance)
    }

    @Test func calendarLinkDetailsRoundTripsThroughCodable() async throws {
        let details = CalendarEventLinkDetails(
            eventIdentifier: "event-1",
            seriesIdentifier: "series-1",
            occurrenceDate: Date(timeIntervalSince1970: 1_713_960_000),
            importScope: .singleOccurrence
        )

        let data = try JSONEncoder().encode(details)
        let decoded = try JSONDecoder().decode(CalendarEventLinkDetails.self, from: data)

        #expect(decoded == details)
    }

    @MainActor
    @Test func softDeleteDescriptorsSeparateActiveAndDeletedCountdowns() async throws {
        let context = try Self.inMemoryContext()
        let active = CountdownItem(
            name: "Active",
            includeTime: false,
            date: Date.now.addingTimeInterval(60)
        )
        let deleted = CountdownItem(
            name: "Deleted",
            includeTime: false,
            date: Date.now.addingTimeInterval(120)
        )
        deleted.isDeleted = true

        context.insert(active)
        context.insert(deleted)
        try context.save()

        let activeItems = try context.fetch(CountdownItem.activeDescriptor())
        let deletedItems = try context.fetch(CountdownItem.deletedDescriptor())

        #expect(activeItems.map(\.id) == [active.id])
        #expect(deletedItems.map(\.id) == [deleted.id])
    }

    @Test func reminderDraftsSortByOffsetThenTitle() async throws {
        let countdown = CountdownItem(
            name: "Launch",
            includeTime: true,
            date: Date.now.addingTimeInterval(3600)
        )
        let laterReminder = CountdownReminder(secondsBeforeEvent: 600, customLabel: "B")
        let firstReminder = CountdownReminder(secondsBeforeEvent: 60, customLabel: "First")
        let alphaReminder = CountdownReminder(secondsBeforeEvent: 600, customLabel: "A")
        countdown.reminders = [laterReminder, firstReminder, alphaReminder]

        #expect(countdown.reminderDrafts.map(\.title) == ["First", "A", "B"])
    }

    @Test func recurringOccurrenceMatchesEvenWhenIdentifierChanges() async throws {
        let occurrenceDate = Date(timeIntervalSince1970: 1_713_960_000)
        let details = CalendarEventLinkDetails(
            eventIdentifier: "original-instance",
            seriesIdentifier: "series-1",
            occurrenceDate: occurrenceDate,
            importScope: .singleOccurrence
        )

        let movedInstance = CalendarEventReference(
            eventIdentifier: "updated-instance",
            seriesIdentifier: "series-1",
            occurrenceDate: occurrenceDate,
            startDate: occurrenceDate.addingTimeInterval(60 * 60),
            isAllDay: false,
            title: "Weekly Standup"
        )

        #expect(CalendarEventLinkMatcher.matches(details: details, candidate: movedInstance))
    }

    @Test func recurringOccurrenceDoesNotJumpToDifferentInstance() async throws {
        let occurrenceDate = Date(timeIntervalSince1970: 1_713_960_000)
        let details = CalendarEventLinkDetails(
            eventIdentifier: "original-instance",
            seriesIdentifier: "series-1",
            occurrenceDate: occurrenceDate,
            importScope: .singleOccurrence
        )

        let nextOccurrence = CalendarEventReference(
            eventIdentifier: "next-instance",
            seriesIdentifier: "series-1",
            occurrenceDate: occurrenceDate.addingTimeInterval(60 * 60 * 24 * 7),
            startDate: occurrenceDate.addingTimeInterval(60 * 60 * 24 * 7),
            isAllDay: false,
            title: "Weekly Standup"
        )

        #expect(!CalendarEventLinkMatcher.matches(details: details, candidate: nextOccurrence))
    }

    @Test func nonRecurringIdentifierStillMatchesDirectly() async throws {
        let details = CalendarEventLinkDetails(
            eventIdentifier: "simple-event",
            seriesIdentifier: nil,
            occurrenceDate: nil,
            importScope: nil
        )

        let candidate = CalendarEventReference(
            eventIdentifier: "simple-event",
            seriesIdentifier: nil,
            occurrenceDate: nil,
            startDate: Date(timeIntervalSince1970: 1_713_960_000),
            isAllDay: false,
            title: "Launch"
        )

        #expect(CalendarEventLinkMatcher.matches(details: details, candidate: candidate))
    }

    @Test func dateListSortsAllDayBeforeTimedEvents() async throws {
        let startOfDay = Date(timeIntervalSince1970: 1_713_960_000)
        let allDay = CalendarEventReference(
            eventIdentifier: "all-day",
            seriesIdentifier: nil,
            occurrenceDate: nil,
            startDate: startOfDay,
            isAllDay: true,
            title: "All-day"
        )
        let timed = CalendarEventReference(
            eventIdentifier: "timed",
            seriesIdentifier: nil,
            occurrenceDate: nil,
            startDate: startOfDay,
            isAllDay: false,
            title: "Timed"
        )

        let sorted = [timed, allDay].sorted {
            if $0.isAllDay != $1.isAllDay {
                return $0.isAllDay && !$1.isAllDay
            }

            if $0.startDate != $1.startDate {
                return $0.startDate < $1.startDate
            }

            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }

        #expect(sorted.map(\.eventIdentifier) == ["all-day", "timed"])
    }

    @MainActor
    private static func inMemoryContext() throws -> ModelContext {
        let schema = Schema([
            CountdownItem.self,
            CountdownReminder.self,
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return container.mainContext
    }

}

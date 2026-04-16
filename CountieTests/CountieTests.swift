//
//  CountieTests.swift
//  CountieTests
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import Foundation
import Testing
@testable import Countie

struct CountieTests {

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

}

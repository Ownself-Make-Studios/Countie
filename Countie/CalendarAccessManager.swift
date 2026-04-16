//
//  CalendarAccessManager.swift
//  Countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit

enum CalendarRecurrenceImportScope: String, Codable {
    case singleOccurrence
}

struct CalendarEventLinkDetails: Equatable {
    let eventIdentifier: String?
    let seriesIdentifier: String?
    let occurrenceDate: Date?
    let importScope: CalendarRecurrenceImportScope?

    var isRecurringImport: Bool {
        importScope == .singleOccurrence && occurrenceDate != nil
    }

    init(
        eventIdentifier: String?,
        seriesIdentifier: String?,
        occurrenceDate: Date?,
        importScope: CalendarRecurrenceImportScope?
    ) {
        self.eventIdentifier = eventIdentifier
        self.seriesIdentifier = seriesIdentifier
        self.occurrenceDate = occurrenceDate
        self.importScope = importScope
    }

    init(event: EKEvent) {
        let isRecurring = event.isDetached
            || event.occurrenceDate != nil
            || !(event.recurrenceRules ?? []).isEmpty

        self.eventIdentifier = event.eventIdentifier
        self.seriesIdentifier = isRecurring ? event.calendarItemExternalIdentifier : nil
        self.occurrenceDate = isRecurring ? (event.occurrenceDate ?? event.startDate) : nil
        self.importScope = isRecurring ? .singleOccurrence : nil
    }
}

struct CalendarEventReference: Equatable {
    let eventIdentifier: String?
    let seriesIdentifier: String?
    let occurrenceDate: Date?
    let startDate: Date
    let isAllDay: Bool
    let title: String

    init(
        eventIdentifier: String?,
        seriesIdentifier: String?,
        occurrenceDate: Date?,
        startDate: Date,
        isAllDay: Bool,
        title: String
    ) {
        self.eventIdentifier = eventIdentifier
        self.seriesIdentifier = seriesIdentifier
        self.occurrenceDate = occurrenceDate
        self.startDate = startDate
        self.isAllDay = isAllDay
        self.title = title
    }

    init(event: EKEvent) {
        let details = CalendarEventLinkDetails(event: event)
        self.init(
            eventIdentifier: event.eventIdentifier,
            seriesIdentifier: details.seriesIdentifier,
            occurrenceDate: details.occurrenceDate,
            startDate: event.startDate,
            isAllDay: event.isAllDay,
            title: event.title
        )
    }
}

enum CalendarEventLinkMatcher {
    private static let matchingCalendar = Calendar.autoupdatingCurrent

    static func matches(
        details: CalendarEventLinkDetails,
        candidate: CalendarEventReference
    ) -> Bool {
        if details.isRecurringImport {
            guard let targetOccurrenceDate = details.occurrenceDate else {
                return false
            }

            let matchesSeries = details.seriesIdentifier == nil
                || details.seriesIdentifier == candidate.seriesIdentifier
            let matchesOccurrence = candidate.occurrenceDate.map {
                matchingCalendar.isDate($0, inSameDayAs: targetOccurrenceDate)
            } ?? false

            return matchesSeries && matchesOccurrence
        }

        return details.eventIdentifier != nil
            && details.eventIdentifier == candidate.eventIdentifier
    }

    static func sortForDateList(_ events: [EKEvent]) -> [EKEvent] {
        events.sorted { lhs, rhs in
            if lhs.isAllDay != rhs.isAllDay {
                return lhs.isAllDay && !rhs.isAllDay
            }

            if lhs.startDate != rhs.startDate {
                return lhs.startDate < rhs.startDate
            }

            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }
}

enum CalendarEventLinkSearchWindow {
    static let recurringResolutionWindow: TimeInterval = 60 * 60 * 24 * 366
}

enum CalendarPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case writeOnly

    var isAuthorized: Bool {
        switch self {
        case .authorized:
            return true
        case .notDetermined, .denied, .restricted, .writeOnly:
            return false
        }
    }
}

struct CalendarAccessManager: Observable {
    static var store = EKEventStore()
    private var hasAccess = false
    private static let searchCalendar = Calendar.autoupdatingCurrent

    static func permissionStatus() -> CalendarPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return .notDetermined
        case .fullAccess:
            return .authorized
        case .writeOnly:
            return .writeOnly
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    static func requestPermission() async -> Bool {
        let status = permissionStatus()

        switch status {
        case .authorized:
            return true
        case .denied, .restricted, .writeOnly:
            return false
        case .notDetermined:
            do {
                let granted = try await store.requestFullAccessToEvents()
                if granted {
                    print("[CALENDARACCESSMANAGER] Access granted")
                } else {
                    print("[CALENDARACCESSMANAGER] Access denied")
                }
                return granted
            } catch {
                print("[CALENDARACCESSMANAGER] Permission request failed: \(error.localizedDescription)")
                return false
            }
        }
    }

    static func event(with identifier: String) -> EKEvent? {
        return store.event(withIdentifier: identifier)
    }

    static func resolveEvent(for countdown: CountdownItem) -> EKEvent? {
        let linkDetails = countdown.calendarEventLinkDetails

        if linkDetails.isRecurringImport,
           let matchedRecurringEvent = resolveRecurringEvent(details: linkDetails) {
            return matchedRecurringEvent
        }

        guard let eventIdentifier = countdown.calendarEventIdentifier else {
            return nil
        }

        return store.event(withIdentifier: eventIdentifier)
    }

    static func events(
        from startDate: Date,
        to endDate: Date,
        calendarIDs: Set<String>? = nil
    ) -> [EKEvent] {
        if let calendarIDs, calendarIDs.isEmpty {
            return []
        }

        let selectedCalendars = selectedCalendars(for: calendarIDs)
        let predicate = store.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: selectedCalendars
        )
        return store.events(matching: predicate)
    }

    static func startOfDay(for date: Date) -> Date {
        searchCalendar.startOfDay(for: date)
    }

    static func endOfDay(for date: Date) -> Date {
        searchCalendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) ?? date
    }

    private static func resolveRecurringEvent(details: CalendarEventLinkDetails) -> EKEvent? {
        guard let occurrenceDate = details.occurrenceDate else {
            return nil
        }

        let startDate = occurrenceDate.addingTimeInterval(-CalendarEventLinkSearchWindow.recurringResolutionWindow)
        let endDate = occurrenceDate.addingTimeInterval(CalendarEventLinkSearchWindow.recurringResolutionWindow)
        let candidates = events(from: startDate, to: endDate)

        let matches = candidates.filter {
            CalendarEventLinkMatcher.matches(
                details: details,
                candidate: CalendarEventReference(event: $0)
            )
        }

        return matches.sorted { lhs, rhs in
            if lhs.eventIdentifier == details.eventIdentifier {
                return true
            }

            if rhs.eventIdentifier == details.eventIdentifier {
                return false
            }

            return lhs.startDate < rhs.startDate
        }.first
    }

    private static func selectedCalendars(for calendarIDs: Set<String>?) -> [EKCalendar]? {
        guard let calendarIDs else { return nil }

        let calendars = store.calendars(for: .event)
        return calendars.filter { calendarIDs.contains($0.calendarIdentifier) }
    }
    
//    static private var eventStoreChangedHandler: (() -> Void)?
//    static private var observer: NSObjectProtocol?
//    
//    static func observeEventStoreChanges(_ handler: @escaping () -> Void) {
//        // Remove previous observer if any
//        if let observer = observer {
//            NotificationCenter.default.removeObserver(observer)
//        }
//        eventStoreChangedHandler = handler
//        observer = NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: store, queue: .main) { _ in
//            handler()
//        }
//    }
//    
//    static func stopObservingEventStoreChanges() {
//        if let observer = observer {
//            NotificationCenter.default.removeObserver(observer)
//            Self.observer = nil
//            eventStoreChangedHandler = nil
//        }
//    }
}

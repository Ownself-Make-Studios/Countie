import Foundation
import SwiftData
import SwiftUI

@Model
final class CountdownItem {
    #Index<CountdownItem>(
        [\.isDeleted, \.date],
        [\.calendarEventIdentifier],
        [\.calendarOccurrenceDate],
        [\.id]
    )

    @Attribute(.unique) var id: UUID = UUID()
    var name: String
    var date: Date
    var isDeleted: Bool = false
    var createdAt: Date = Date.now
    var countSince: Date = Date.now
    var iconName: String = CountdownEventIcon.default
    
    var color: CountdownEventColor = CountdownEventColor.blue
    
    var calendarEventIdentifier: String?
    var calendarSeriesIdentifier: String?
    var calendarOccurrenceDate: Date?
    var calendarRecurrenceImportScopeRaw: String?

    init(
        name: String,
        date: Date,
        iconName: String = CountdownEventIcon.default,
        color: CountdownEventColor = CountdownEventColor.blue,
        calendarEventIdentifier: String? = nil
    ) {
        self.name = name
        self.date = date
        self.iconName = iconName
        self.color = color
        self.calendarEventIdentifier = calendarEventIdentifier
    }

    convenience init(
        name: String,
        date: Date,
        calendarEventIdentifier: String? = nil
    ) {
        self.init(
            name: name,
            date: date,
            iconName: CountdownEventIcon.default,
            color: .blue,
            calendarEventIdentifier: calendarEventIdentifier
        )
    }

    var resolvedIconName: String {
        CountdownEventIcon.allSymbols.contains(iconName) ? iconName : CountdownEventIcon.default
    }

    var eventTintColor: Color {
        color.color
    }

    var calendarRecurrenceImportScope: CalendarRecurrenceImportScope? {
        get {
            guard let calendarRecurrenceImportScopeRaw else { return nil }
            return CalendarRecurrenceImportScope(rawValue: calendarRecurrenceImportScopeRaw)
        }
        set {
            calendarRecurrenceImportScopeRaw = newValue?.rawValue
        }
    }

    var calendarEventLinkDetails: CalendarEventLinkDetails {
        get {
            CalendarEventLinkDetails(
                eventIdentifier: calendarEventIdentifier,
                seriesIdentifier: calendarSeriesIdentifier,
                occurrenceDate: calendarOccurrenceDate,
                importScope: calendarRecurrenceImportScope
            )
        }
        set {
            calendarEventIdentifier = newValue.eventIdentifier
            calendarSeriesIdentifier = newValue.seriesIdentifier
            calendarOccurrenceDate = newValue.occurrenceDate
            calendarRecurrenceImportScope = newValue.importScope
        }
    }

    static func activeDescriptor() -> FetchDescriptor<CountdownItem> {
        FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.isDeleted == false
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
    }

    static func deletedDescriptor() -> FetchDescriptor<CountdownItem> {
        FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.isDeleted == true
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
    }

    static func upcomingDescriptor(since date: Date = .now, limit: Int? = nil) -> FetchDescriptor<CountdownItem> {
        var descriptor = FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.isDeleted == false && item.date >= date
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
        if let limit {
            descriptor.fetchLimit = limit
        }
        return descriptor
    }

    static func activeDescriptor(id: UUID) -> FetchDescriptor<CountdownItem> {
        FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.id == id && item.isDeleted == false
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
    }

    static func appEntityDescriptor(includePast: Bool, since date: Date = .now) -> FetchDescriptor<CountdownItem> {
        FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.isDeleted == false && (includePast || item.date >= date)
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
    }

    static func calendarLinkedUpcomingDescriptor(since date: Date = .now) -> FetchDescriptor<CountdownItem> {
        FetchDescriptor<CountdownItem>(
            predicate: #Predicate<CountdownItem> { item in
                item.isDeleted == false
                    && (item.calendarEventIdentifier != nil || item.calendarOccurrenceDate != nil)
                    && item.date >= date
            },
            sortBy: [SortDescriptor(\.date, order: .forward)]
        )
    }
}

import Foundation
import SwiftData

extension CountdownItem {
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

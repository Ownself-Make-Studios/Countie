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


// MARK - LOL
extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(
        name: "Demo Item (Future)",
        date: .distantFuture,
        iconName: "sparkles",
        color: .blue
    )

    public static var SamplePastTimer = CountdownItem(
        name: "Demo Item (Past)",
        date: Date.now.addingTimeInterval(-86400),
        iconName: "clock.fill",
        color: .cyan
    )

    public static var Graduation = CountdownItem(
        name: "Graduation",
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30),
        iconName: "graduationcap.fill",
        color: .orange
    )
}

// MARK - Time Formatting
enum CountdownUnit: String, CaseIterable {
    case year, month, day, hour, minute

    var displayName: String {
        rawValue
    }
}

struct BiggestUnit {
    let value: Int
    let unit: CountdownUnit
    var isPast: Bool { value < 0 }
}

extension CountdownItem {
    private var dateDifference: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: Date.now,
            to: date
        )
    }

    func getTimeRemainingFn(since: Date = .now) -> String {
        let calendar = Calendar.current
        let startOfSince = calendar.startOfDay(for: since)
        let startOfDate = calendar.startOfDay(for: date)
        let isToday = calendar.isDate(startOfDate, inSameDayAs: startOfSince)
        let interval = date.timeIntervalSince(since)

        if isToday {
            return String(localized: "Today")
        }

        if interval > 0 {
            let daysLeft = calendar.dateComponents([.day], from: startOfSince, to: startOfDate).day ?? 0
            if daysLeft > 0 {
                return Self.localizedDayCount(daysLeft)
            }
            return getTimeRemainingString(since: since, units: [.hour])
        } else {
            let daysAgo = calendar.dateComponents([.day], from: startOfDate, to: startOfSince).day ?? 0
            let dayCount = Self.localizedDayCount(daysAgo)
            return String(
                localized: "\(dayCount) ago",
                comment: "A localized duration since a countdown ended."
            )
        }
    }

    private static func localizedDayCount(_ count: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day]
        formatter.unitsStyle = .full
        return formatter.string(from: DateComponents(day: count)) ?? "\(count)"
    }

    func getTimeRemainingString(
        since: Date = .now,
        units: NSCalendar.Unit = [.year, .month, .day, .hour],
        unitsStyle: DateComponentsFormatter.UnitsStyle = .full
    ) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = unitsStyle
        guard let text = formatter.string(from: since, to: date) else { return "?" }
        return text.hasPrefix("-")
            ? String(
                localized: "\(text.dropFirst()) ago",
                comment: "A localized duration since a countdown ended."
            )
            : text
    }

    var progress: Double {
        let total = date.timeIntervalSince(countSince)
        let elapsed = Date().timeIntervalSince(countSince)
        guard total > 0 else { return 1.0 }
        return min(max(elapsed / total, 0), 1)
    }

    var progressString: String {
        String(format: "%.2f", progress * 100)
    }

    var biggestUnit: BiggestUnit? {
        if let year = dateDifference.year, year > 0 { return BiggestUnit(value: year, unit: .year) }
        if let month = dateDifference.month, month > 0 { return BiggestUnit(value: month, unit: .month) }
        if let day = dateDifference.day, day > 0 { return BiggestUnit(value: day, unit: .day) }
        if let hour = dateDifference.hour, hour > 0 { return BiggestUnit(value: hour, unit: .hour) }
        if let minute = dateDifference.minute, minute > 0 { return BiggestUnit(value: minute, unit: .minute) }
        return nil
    }

    var biggestUnitShortString: String {
        guard let unit = biggestUnit else { return "?" }
        let absValue = abs(unit.value)
        let suffix = unit.isPast ? " ago" : ""
        let symbol: String
        switch unit.unit {
        case .year: symbol = "y"
        case .month: symbol = "m"
        case .day: symbol = "d"
        case .hour: symbol = "h"
        case .minute: symbol = "m"
        }
        return "\(absValue)\(symbol)\(suffix)"
    }

    var formattedDateString: String {
        date.formatted(date: .long, time: .omitted)
    }

    var formattedDateTimeString: String {
        date.formatted(date: .long, time: .shortened)
    }
}

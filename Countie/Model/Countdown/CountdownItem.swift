import Foundation
import SwiftData

@Model
final class CountdownItem {
    #Index<CountdownItem>(
        [\.isDeleted, \.date],
        [\.calendarEventIdentifier],
        [\.calendarOccurrenceDate],
        [\.id]
    )

    @Attribute(.unique) var id: UUID = UUID()
    var appearance: CountdownAppearance
    var name: String
    var includeTime: Bool = false
    var date: Date
    var isDeleted: Bool = false
    var createdAt: Date = Date.now
    var countSince: Date = Date.now
    var calendarEventIdentifier: String?
    var calendarSeriesIdentifier: String?
    var calendarOccurrenceDate: Date?
    var calendarRecurrenceImportScopeRaw: String?

    @Relationship(deleteRule: .cascade, inverse: \CountdownReminder.countdown)
    var reminders: [CountdownReminder] = []

    init(
        name: String,
        includeTime: Bool,
        date: Date,
        iconName: String = CountdownEventIcon.default,
        colorNameRaw: String = CountdownEventColor.blue.rawValue,
        calendarEventIdentifier: String? = nil
    ) {
        self.appearance = CountdownAppearance(iconName: iconName, colorRawValue: colorNameRaw)
        self.name = name
        self.includeTime = includeTime
        self.date = date
        self.calendarEventIdentifier = calendarEventIdentifier
    }

    convenience init(
        name: String,
        includeTime: Bool,
        date: Date,
        calendarEventIdentifier: String? = nil
    ) {
        self.init(
            name: name,
            includeTime: includeTime,
            date: date,
            iconName: CountdownEventIcon.default,
            colorNameRaw: CountdownEventColor.blue.rawValue,
            calendarEventIdentifier: calendarEventIdentifier
        )
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

    var reminderDrafts: [CountdownReminderDraft] {
        reminders
            .map(CountdownReminderDraft.fromModel)
            .sorted { lhs, rhs in
                if lhs.secondsBeforeEvent == rhs.secondsBeforeEvent {
                    return lhs.title < rhs.title
                }
                return lhs.secondsBeforeEvent < rhs.secondsBeforeEvent
            }
    }
}

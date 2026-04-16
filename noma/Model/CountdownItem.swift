import AppIntents
import Foundation
import SwiftData

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

@Model
class CountdownItem {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var emoji: String?
    @Attribute var name: String
    @Attribute var includeTime: Bool = false
    @Attribute var date: Date
    @Attribute var isDeleted: Bool = false
    @Attribute var createdAt: Date = Date.now
    @Attribute var countSince: Date = Date.now
    @Attribute var calendarEventIdentifier: String?
    @Relationship(deleteRule: .cascade, inverse: \CountdownReminder.countdown)
    var reminders: [CountdownReminder] = []

    init(
        emoji: String?,
        name: String,
        includeTime: Bool,
        date: Date,
        calendarEventIdentifier: String? = nil
    ) {
        self.emoji = emoji
        self.name = name
        self.includeTime = includeTime
        self.date = date
        self.calendarEventIdentifier = calendarEventIdentifier
    }

    private var dateDifference: DateComponents {
        Calendar.autoupdatingCurrent.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: Date.now,
            to: date
        )
    }

    private func getLeft(_ unit: Calendar.Component) -> Int {
        dateDifference.value(for: unit) ?? 0
    }

    private func roundedUpDaysRemaining(since: Date = Date.now) -> Int {
        let interval = date.timeIntervalSince(since)
        return interval > 0 ? Int(ceil(interval / 86400)) : 0
    }

    func getTimeRemainingFn(since: Date = .now) -> String {
        let calendar = Calendar.current
        let startOfSince = calendar.startOfDay(for: since)
        let startOfDate = calendar.startOfDay(for: date)
        let isToday = calendar.isDate(startOfDate, inSameDayAs: startOfSince)
        let interval = date.timeIntervalSince(since)
//        if isToday && interval >= 0 {
        if isToday {
            // Show 'Today' if event is today and in the future
            return "Today"
        }
        if interval > 0 {
            // Future event: show the number of full days left (ignore time)
            let daysLeft = calendar.dateComponents([.day], from: startOfSince, to: startOfDate).day ?? 0
            if daysLeft > 0 { return "\(daysLeft) day" + (daysLeft > 1 ? "s" : "") }
            // fallback to hours if less than a day (should not happen, but for safety)
            return getTimeRemainingString(since: since, units: [.hour])
        } else {
            // Past event: show the number of full days ago
            let daysAgo = calendar.dateComponents([.day], from: startOfDate, to: startOfSince).day ?? 0
            return "\(daysAgo) day" + (daysAgo != 1 ? "s" : "") + " ago"
        }
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
        return text.hasPrefix("-") ? "\(text.dropFirst()) ago" : text
    }

//    func getTimeRemainingPassedFn(since: Date = .now) -> String {
//        getLeft(.day) <= 0
//            ? getTimeRemainingString(since: since, units: [.day])
//            : getTimeRemainingString(since: since, units: [.hour])
//    }

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
        let diff = dateDifference
        if let y = diff.year, y != 0 { return BiggestUnit(value: y, unit: .year) }
        if let m = diff.month, m != 0 { return BiggestUnit(value: m, unit: .month) }
        if let d = diff.day, d != 0 { return BiggestUnit(value: d, unit: .day) }
        var h = diff.hour ?? 0
        let min = diff.minute ?? 0
        if h == 0 && min != 0 { h = min > 0 ? 1 : -1 }
        else if h != 0 && min != 0 && ((h > 0 && min > 0) || (h < 0 && min < 0)) {
            h += h > 0 ? 1 : -1
        }
        if h != 0 { return BiggestUnit(value: h, unit: .hour) }
        if let min = diff.minute, min != 0 { return BiggestUnit(value: min, unit: .minute) }
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
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .none
        return df.string(from: date)
    }

    var formattedDateTimeString: String {
        let df = DateFormatter()
        df.dateStyle = .long
        df.timeStyle = .short
        return df.string(from: date)
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

extension CountdownItem {
    public static var SampleFutureTimer = CountdownItem(
        emoji: "😊",
        name: "Demo Item (Future)",
        includeTime: true,
        date: .distantFuture
    )

    public static var SamplePastTimer = CountdownItem(
        emoji: nil,
        name: "Demo Item (Past)",
        includeTime: true,
        date: Date.now.addingTimeInterval(-86400)
    )

    public static var Graduation = CountdownItem(
        emoji: "🎓",
        name: "Graduation",
        includeTime: false,
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30)
    )
}

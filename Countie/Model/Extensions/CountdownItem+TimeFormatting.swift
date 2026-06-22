import Foundation

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
            return "Today"
        }

        if interval > 0 {
            let daysLeft = calendar.dateComponents([.day], from: startOfSince, to: startOfDate).day ?? 0
            if daysLeft > 0 { return "\(daysLeft) day" + (daysLeft > 1 ? "s" : "") }
            return getTimeRemainingString(since: since, units: [.hour])
        } else {
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
        if h == 0 && min != 0 {
            h = min > 0 ? 1 : -1
        } else if h != 0 && min != 0 && ((h > 0 && min > 0) || (h < 0 && min < 0)) {
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
}

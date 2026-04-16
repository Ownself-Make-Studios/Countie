import AppIntents
import Foundation
import SwiftData
import SwiftUI

private extension Color {
    static func palette(_ red: Int, _ green: Int, _ blue: Int) -> Color {
        Color(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0
        )
    }
}

enum CountdownEventColor: String, CaseIterable, Codable, Identifiable {
    case berry
    case brick
    case orange
    case gold
    case peach
    case apricot
    case cream
    case sand
    case salmon
    case blush
    case coral
    case pink
    case mauve
    case lavender
    case periwinkle
    case violet
    case purple
    case slate
    case blue
    case sea
    case cyan
    case mint
    case sage
    case mist
    case stone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .berry: "Berry"
        case .brick: "Brick"
        case .orange: "Orange"
        case .gold: "Gold"
        case .peach: "Peach"
        case .apricot: "Apricot"
        case .cream: "Cream"
        case .sand: "Sand"
        case .salmon: "Salmon"
        case .blush: "Blush"
        case .coral: "Coral"
        case .pink: "Pink"
        case .mauve: "Mauve"
        case .lavender: "Lavender"
        case .periwinkle: "Periwinkle"
        case .violet: "Violet"
        case .purple: "Purple"
        case .slate: "Slate"
        case .blue: "Blue"
        case .sea: "Sea"
        case .cyan: "Cyan"
        case .mint: "Mint"
        case .sage: "Sage"
        case .mist: "Mist"
        case .stone: "Stone"
        }
    }

    var color: Color {
        switch self {
        case .berry:
            return .palette(124, 68, 79)
        case .brick:
            return .palette(159, 82, 85)
        case .orange:
            return .palette(255, 145, 71)
        case .gold:
            return .palette(237, 184, 105)
        case .peach:
            return .palette(255, 180, 162)
        case .apricot:
            return .palette(255, 205, 178)
        case .cream:
            return .palette(255, 242, 239)
        case .sand:
            return .palette(242, 234, 224)
        case .salmon:
            return .palette(250, 104, 104)
        case .blush:
            return .palette(247, 165, 165)
        case .coral:
            return .palette(255, 115, 148)
        case .pink:
            return .palette(255, 92, 163)
        case .mauve:
            return .palette(221, 174, 211)
        case .lavender:
            return .palette(189, 166, 206)
        case .periwinkle:
            return .palette(155, 142, 199)
        case .violet:
            return .palette(127, 85, 177)
        case .purple:
            return .palette(196, 87, 245)
        case .slate:
            return .palette(93, 104, 138)
        case .blue:
            return .palette(94, 133, 255)
        case .sea:
            return .palette(90, 156, 181)
        case .cyan:
            return .palette(64, 186, 242)
        case .mint:
            return .palette(79, 209, 189)
        case .sage:
            return .palette(111, 143, 114)
        case .mist:
            return .palette(180, 211, 217)
        case .stone:
            return .palette(191, 198, 196)
        }
    }
}

enum CountdownEventIcon {
    static let `default` = "calendar"

    struct Entry: Identifiable, Hashable {
        let symbolName: String
        let label: String
        let keywords: [String]

        var id: String { symbolName }

        func matches(_ query: String) -> Bool {
            let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !needle.isEmpty else { return true }

            if label.lowercased().contains(needle) || symbolName.lowercased().contains(needle) {
                return true
            }

            return keywords.contains { $0.lowercased().contains(needle) }
        }
    }

    static let allEntries: [Entry] = [
        .init(symbolName: "calendar", label: "Calendar", keywords: ["generic", "default", "schedule", "date"]),
        .init(symbolName: "alarm", label: "Alarm", keywords: ["wake", "time", "clock"]),
        .init(symbolName: "airplane.departure", label: "Flight", keywords: ["trip", "travel", "vacation", "plane"]),
        .init(symbolName: "tram.fill", label: "Transit", keywords: ["train", "commute", "transport"]),
        .init(symbolName: "car.fill", label: "Car", keywords: ["drive", "road trip", "vehicle"]),
        .init(symbolName: "location.fill", label: "Location", keywords: ["place", "pin", "meetup", "destination"]),
        .init(symbolName: "map.fill", label: "Map", keywords: ["travel", "route", "adventure"]),
        .init(symbolName: "suitcase.fill", label: "Suitcase", keywords: ["travel", "trip", "holiday", "luggage"]),
        .init(symbolName: "house.fill", label: "Home", keywords: ["move", "housewarming", "family"]),
        .init(symbolName: "building.2.fill", label: "Office", keywords: ["work", "company", "business"]),
        .init(symbolName: "briefcase.fill", label: "Work", keywords: ["job", "career", "office"]),
        .init(symbolName: "lanyardcard.fill", label: "Pass", keywords: ["badge", "conference", "event"]),
        .init(symbolName: "graduationcap.fill", label: "Graduation", keywords: ["school", "college", "exam", "study"]),
        .init(symbolName: "book.fill", label: "Books", keywords: ["study", "reading", "school", "learning"]),
        .init(symbolName: "checkmark.seal.fill", label: "Milestone", keywords: ["goal", "achievement", "success"]),
        .init(symbolName: "medal.fill", label: "Medal", keywords: ["award", "achievement", "success"]),
        .init(symbolName: "trophy.fill", label: "Trophy", keywords: ["win", "champion", "award", "competition"]),
        .init(symbolName: "flag.fill", label: "Flag", keywords: ["goal", "finish", "target", "milestone"]),
        .init(symbolName: "star.fill", label: "Star", keywords: ["favorite", "special", "highlight"]),
        .init(symbolName: "sparkles", label: "Sparkles", keywords: ["celebration", "magic", "special", "new year"]),
        .init(symbolName: "fireworks", label: "Fireworks", keywords: ["celebration", "festival", "holiday", "party"]),
        .init(symbolName: "party.popper.fill", label: "Party", keywords: ["celebration", "birthday", "event"]),
        .init(symbolName: "balloon.2.fill", label: "Balloons", keywords: ["party", "birthday", "celebration"]),
        .init(symbolName: "birthday.cake.fill", label: "Birthday Cake", keywords: ["birthday", "cake", "party"]),
        .init(symbolName: "gift.fill", label: "Gift", keywords: ["present", "birthday", "holiday", "surprise"]),
        .init(symbolName: "heart.fill", label: "Heart", keywords: ["love", "anniversary", "wedding", "date"]),
        .init(symbolName: "theatermasks.fill", label: "Theater", keywords: ["show", "concert", "drama", "performance"]),
        .init(symbolName: "ticket.fill", label: "Ticket", keywords: ["concert", "show", "movie", "entry"]),
        .init(symbolName: "music.mic", label: "Concert", keywords: ["music", "singing", "karaoke", "performance"]),
        .init(symbolName: "film.fill", label: "Movie", keywords: ["cinema", "show", "watch"]),
        .init(symbolName: "tv.fill", label: "TV", keywords: ["series", "show", "watch party"]),
        .init(symbolName: "camera.fill", label: "Camera", keywords: ["photo", "photoshoot", "picture"]),
        .init(symbolName: "photo.fill", label: "Photo", keywords: ["memory", "gallery", "picture"]),
        .init(symbolName: "phone.fill", label: "Phone", keywords: ["call", "launch", "device"]),
        .init(symbolName: "bell.fill", label: "Bell", keywords: ["reminder", "alert", "notification"]),
        .init(symbolName: "clock.fill", label: "Clock", keywords: ["deadline", "time", "countdown"]),
        .init(symbolName: "moon.stars.fill", label: "Night", keywords: ["sleep", "evening", "overnight"]),
        .init(symbolName: "sun.max.fill", label: "Sunny Day", keywords: ["summer", "holiday", "outdoor"]),
        .init(symbolName: "leaf.fill", label: "Nature", keywords: ["garden", "plant", "spring", "outdoor"]),
        .init(symbolName: "tree.fill", label: "Tree", keywords: ["nature", "holiday", "park", "camping"]),
        .init(symbolName: "tent.fill", label: "Camping", keywords: ["trip", "outdoor", "adventure"]),
        .init(symbolName: "pawprint.fill", label: "Pet", keywords: ["dog", "cat", "animal", "vet"]),
        .init(symbolName: "pill.fill", label: "Medicine", keywords: ["health", "doctor", "appointment"]),
        .init(symbolName: "stethoscope", label: "Doctor", keywords: ["health", "clinic", "medical"]),
        .init(symbolName: "dumbbell.fill", label: "Workout", keywords: ["gym", "fitness", "exercise"]),
        .init(symbolName: "figure.run", label: "Run", keywords: ["marathon", "race", "fitness", "sport"]),
        .init(symbolName: "sportscourt.fill", label: "Sports", keywords: ["game", "match", "practice", "tournament"]),
        .init(symbolName: "baseball.fill", label: "Baseball", keywords: ["sport", "game", "match"]),
        .init(symbolName: "fork.knife", label: "Dinner", keywords: ["food", "meal", "restaurant", "date"]),
        .init(symbolName: "cup.and.saucer.fill", label: "Coffee", keywords: ["cafe", "brunch", "breakfast"]),
        .init(symbolName: "wineglass.fill", label: "Drinks", keywords: ["party", "dinner", "celebration"]),
        .init(symbolName: "popcorn.fill", label: "Popcorn", keywords: ["movie", "snack", "cinema"]),
        .init(symbolName: "cart.fill", label: "Shopping", keywords: ["buy", "mall", "purchase"]),
        .init(symbolName: "wrench.and.screwdriver.fill", label: "Project", keywords: ["build", "fix", "launch", "work"]),
        .init(symbolName: "megaphone.fill", label: "Announcement", keywords: ["launch", "promo", "marketing"]),
        .init(symbolName: "person.2.fill", label: "People", keywords: ["friends", "family", "team", "group"]),
        .init(symbolName: "bed.double.fill", label: "Staycation", keywords: ["hotel", "rest", "weekend"]),
        .init(symbolName: "bag.fill", label: "Bag", keywords: ["shopping", "errand", "purchase"]),
        .init(symbolName: "scissors", label: "Salon", keywords: ["haircut", "grooming", "beauty"]),
        .init(symbolName: "paintpalette.fill", label: "Creative", keywords: ["art", "design", "craft"]),
        .init(symbolName: "gamecontroller.fill", label: "Gaming", keywords: ["game", "play", "esports"]),
        .init(symbolName: "bicycle", label: "Cycling", keywords: ["bike", "ride", "exercise"]),
        .init(symbolName: "figure.yoga", label: "Yoga", keywords: ["wellness", "fitness", "meditation"]),
        .init(symbolName: "cross.case.fill", label: "Hospital", keywords: ["medical", "health", "doctor"]),
        .init(symbolName: "banknote.fill", label: "Finance", keywords: ["payday", "money", "budget", "bill"]),
        .init(symbolName: "creditcard.fill", label: "Payment", keywords: ["bill", "money", "purchase"]),
        .init(symbolName: "envelope.fill", label: "Mail", keywords: ["letter", "invite", "message"]),
        .init(symbolName: "paperplane.fill", label: "Send", keywords: ["launch", "message", "travel"]),
        .init(symbolName: "shippingbox.fill", label: "Delivery", keywords: ["package", "shipment", "order"]),
        .init(symbolName: "archivebox.fill", label: "Storage", keywords: ["packing", "move", "organize"]),
        .init(symbolName: "hammer.fill", label: "Build", keywords: ["project", "home", "renovation"]),
        .init(symbolName: "sofa.fill", label: "Furniture", keywords: ["home", "move", "decor"]),
        .init(symbolName: "washer.fill", label: "Laundry", keywords: ["chores", "home"]),
        .init(symbolName: "printer.fill", label: "Print", keywords: ["documents", "office", "school"]),
        .init(symbolName: "globe.americas.fill", label: "World", keywords: ["travel", "global", "international"]),
        .init(symbolName: "mountain.2.fill", label: "Hike", keywords: ["outdoor", "nature", "trip"]),
        .init(symbolName: "beach.umbrella.fill", label: "Beach", keywords: ["vacation", "summer", "trip"]),
        .init(symbolName: "snowflake", label: "Winter", keywords: ["holiday", "snow", "trip"]),
        .init(symbolName: "giftcard.fill", label: "Gift Card", keywords: ["present", "shopping", "birthday"])
    ]

    static let allSymbols = allEntries.map(\.symbolName)
}

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
    @Attribute var iconName: String?
    @Attribute var colorNameRaw: String?
    @Attribute var name: String
    @Attribute var includeTime: Bool = false
    @Attribute var date: Date
    @Attribute var isDeleted: Bool = false
    @Attribute var createdAt: Date = Date.now
    @Attribute var countSince: Date = Date.now
    @Attribute var calendarEventIdentifier: String?
    @Attribute var calendarSeriesIdentifier: String?
    @Attribute var calendarOccurrenceDate: Date?
    @Attribute var calendarRecurrenceImportScopeRaw: String?
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
        self.iconName = iconName
        self.colorNameRaw = colorNameRaw
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

    var resolvedIconName: String {
        guard let iconName, CountdownEventIcon.allSymbols.contains(iconName) else {
            return CountdownEventIcon.default
        }
        return iconName
    }

    var eventColor: CountdownEventColor {
        get { CountdownEventColor(rawValue: colorNameRaw ?? "") ?? .blue }
        set { colorNameRaw = newValue.rawValue }
    }

    var eventTintColor: Color {
        eventColor.color
    }

    @discardableResult
    func normalizeAppearance() -> Bool {
        var didChange = false

        if !CountdownEventIcon.allSymbols.contains(iconName ?? "") {
            iconName = CountdownEventIcon.default
            didChange = true
        }

        if CountdownEventColor(rawValue: colorNameRaw ?? "") == nil {
            colorNameRaw = CountdownEventColor.blue.rawValue
            didChange = true
        }

        return didChange
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
        CalendarEventLinkDetails(
            eventIdentifier: calendarEventIdentifier,
            seriesIdentifier: calendarSeriesIdentifier,
            occurrenceDate: calendarOccurrenceDate,
            importScope: calendarRecurrenceImportScope
        )
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
        name: "Demo Item (Future)",
        includeTime: true,
        date: .distantFuture,
        iconName: "sparkles",
        colorNameRaw: CountdownEventColor.blue.rawValue
    )

    public static var SamplePastTimer = CountdownItem(
        name: "Demo Item (Past)",
        includeTime: true,
        date: Date.now.addingTimeInterval(-86400),
        iconName: "clock.fill",
        colorNameRaw: CountdownEventColor.cyan.rawValue
    )

    public static var Graduation = CountdownItem(
        name: "Graduation",
        includeTime: false,
        date: Date.now.addingTimeInterval(60 * 60 * 24 * 30),
        iconName: "graduationcap.fill",
        colorNameRaw: CountdownEventColor.orange.rawValue
    )
}

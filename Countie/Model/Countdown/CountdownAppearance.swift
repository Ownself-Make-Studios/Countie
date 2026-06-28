import Foundation
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

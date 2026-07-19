import AppIntents
import UIKit
import Foundation
import SwiftData
import CoreSpotlight

public struct CountdownEntity: IndexedEntity {
    public static var typeDisplayRepresentation = TypeDisplayRepresentation(
        name: "Countdown"
    )

    public static var defaultQuery = CountdownEntityQuery()

    public let id: String
    public var name: String
    public var date: Date
    
    @Property
    public var iconName: String

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(name)",
            subtitle: "\(date.formatted(date: .abbreviated, time: .shortened))",
            image: .init(systemName: iconName)
        )
    }
    
    public var attributeSet: CSSearchableItemAttributeSet {
        let set = CSSearchableItemAttributeSet(contentType: .calendarEvent)
        
        set.identifier = id
        set.title = name
        set.dueDate = date
        
        set.setValue(date, forKey: "expirationDate")
        set.contentDescription = String(
            localized: "Countdown tracking the time until \(name).",
            comment: "Spotlight description for a countdown. The variable is its name."
        )
        
        // Image data
        if let imageProvider = UIImage(systemName: iconName),
                   let data = imageProvider.pngData() {
                    set.thumbnailData = data
                }
        
        return set
    }

    init(item: CountdownItem) {
        self.id = item.id.uuidString;
        self.name = item.name;
        self.date = item.date;
        self.iconName = item.resolvedIconName;
    }
}

public struct CountdownEntityQuery: EntityStringQuery {
    public init() {}

    public func entities(for identifiers: [CountdownEntity.ID]) async throws -> [CountdownEntity] {
        let identifierSet = Set(identifiers)
        return await fetchCountdownEntities(includePast: true)
            .filter { identifierSet.contains($0.id) }
    }

    public func suggestedEntities() async throws -> [CountdownEntity] {
        await fetchCountdownEntities(includePast: false)
    }

    public func entities(matching string: String) async throws -> [CountdownEntity] {
        let searchText = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchText.isEmpty else {
            return await fetchCountdownEntities(includePast: false)
        }

        return await fetchCountdownEntities(includePast: true)
            .filter { entity in
                entity.name.localizedCaseInsensitiveContains(searchText)
                    || entity.date.formatted(date: .abbreviated, time: .omitted)
                        .localizedCaseInsensitiveContains(searchText)
                    || entity.date.formatted(date: .complete, time: .shortened)
                        .localizedCaseInsensitiveContains(searchText)
            }
    }

    @MainActor
    private func fetchCountdownEntities(includePast: Bool) async -> [CountdownEntity] {
        let container = CountieModelContainer.sharedModelContainer
        let descriptor = CountdownItem.appEntityDescriptor(includePast: includePast)
        let items = (try? container.mainContext.fetch(descriptor)) ?? []
        return items.map { CountdownEntity(item: $0) }
    }
}

enum CountdownEntityContext {
    @MainActor
    static func identifier(for item: CountdownItem) -> EntityIdentifier {
        if #available(iOS 27.0, *) {
            EntityIdentifier(for: CountieCalendarEventEntity(item: item))
        } else {
            EntityIdentifier(for: CountdownEntity(item: item))
        }
    }
}

enum CountdownSearchIndex {
    static func index(_ item: CountdownItem) {
        let entity = CountdownEntity(item: item)

        Task {
            do {
                try await CSSearchableIndex.default().indexAppEntities([entity])
            } catch {
                print("Failed to index countdown: \(error)")
            }
        }
    }

    static func delete(id: UUID) {
        Task {
            do {
                try await CSSearchableIndex.default().deleteAppEntities(
                    identifiedBy: [id.uuidString],
                    ofType: CountdownEntity.self
                )
            } catch {
                print("Failed to delete indexed countdown: \(error)")
            }
        }
    }
}

// MARK: - iOS 27 Calendar schema

@available(iOS 27.0, *)
@AppEntity(schema: .calendar.calendar)
struct CountieCalendarEntity {
    static let defaultQuery = CountieCalendarEntityQuery()

    let id: String
    var title: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            image: .init(systemName: "calendar")
        )
    }

    init() {
        id = "countie"
        title = "Countie"
    }

    struct CountieCalendarEntityQuery: EntityQuery {
        func entities(for identifiers: [String]) async throws -> [CountieCalendarEntity] {
            identifiers.contains("countie") ? [CountieCalendarEntity()] : []
        }
    }
}

@available(iOS 27.0, *)
@AppEnum(schema: .calendar.attendeeStatus)
enum CountieAttendeeStatus: String {
    case pending
    case accepted
    case declined
    case tentative

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .pending: "Pending",
        .accepted: "Accepted",
        .declined: "Declined",
        .tentative: "Tentative"
    ]
}

@available(iOS 27.0, *)
@AppEnum(schema: .calendar.attendeeType)
enum CountieAttendeeType: String {
    case person

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .person: "Person"
    ]
}

@available(iOS 27.0, *)
@AppEntity(schema: .calendar.attendee)
struct CountieAttendeeEntity {
    static let defaultQuery = CountieAttendeeEntityQuery()

    let id: String
    var person: IntentPerson
    var status: CountieAttendeeStatus?
    var isAttendanceOptional: Bool
    var type: CountieAttendeeType?

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(person)")
    }

    struct CountieAttendeeEntityQuery: EntityQuery {
        func entities(for identifiers: [String]) async throws -> [CountieAttendeeEntity] {
            []
        }
    }
}

@available(iOS 27.0, *)
@AppEnum(schema: .calendar.eventStatus)
enum CountieEventStatus: String {
    case confirmed
    case tentative
    case cancelled

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .confirmed: "Confirmed",
        .tentative: "Tentative",
        .cancelled: "Cancelled"
    ]
}

@available(iOS 27.0, *)
@UnionValue
enum CountieEventLocation {
    case name(String)
}

@available(iOS 27.0, *)
@UnionValue
enum CountieEventAlarm {
    case relative(Duration)
    case absolute(Date)
}

@available(iOS 27.0, *)
@AppEntity(schema: .calendar.event)
struct CountieCalendarEventEntity {
    static let defaultQuery = CountieCalendarEventEntityQuery()

    let id: String
    var calendar: CountieCalendarEntity
    var title: String
    var startDate: Date
    var endDate: Date
    var isAllDay: Bool
    var recurrence: Calendar.RecurrenceRule?
    var note: AttributedString?
    var travelTime: Duration?
    var location: CountieEventLocation?
    var virtualLocation: URL?
    var status: CountieEventStatus?
    var alarms: [CountieEventAlarm]
    var organizers: [IntentPerson]
    var attendees: [CountieAttendeeEntity]

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(startDate.formatted(date: .abbreviated, time: .shortened))",
            image: .init(systemName: "calendar.badge.clock")
        )
    }

    init(item: CountdownItem) {
        id = item.id.uuidString
        calendar = CountieCalendarEntity()
        title = item.name
        startDate = item.date
        endDate = item.date
        isAllDay = false
        recurrence = nil
        note = nil
        travelTime = nil
        location = nil
        virtualLocation = nil
        status = .confirmed
        alarms = []
        organizers = []
        attendees = []
    }

    struct CountieCalendarEventEntityQuery: EntityQuery {
        func entities(for identifiers: [String]) async throws -> [CountieCalendarEventEntity] {
            try await MainActor.run {
                let identifierSet = Set(identifiers)
                let descriptor = CountdownItem.appEntityDescriptor(includePast: true)
                let items = try CountieModelContainer.sharedModelContainer.mainContext.fetch(descriptor)
                return items
                    .filter { identifierSet.contains($0.id.uuidString) }
                    .map(CountieCalendarEventEntity.init(item:))
            }
        }
    }
}

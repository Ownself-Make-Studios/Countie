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
        set.contentDescription = "Countdown tracking the days until \(name)."
        
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

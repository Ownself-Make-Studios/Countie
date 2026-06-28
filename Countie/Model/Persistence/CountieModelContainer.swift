import Foundation
import SwiftData

struct CountieModelContainer {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CountdownItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            resetStoreFiles(for: modelConfiguration)
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer after resetting store: \(error)")
            }
        }
    }()

    private static func resetStoreFiles(for configuration: ModelConfiguration) {
        let storeURL = configuration.url
        let fileManager = FileManager.default
        let sidecarURLs = [
            storeURL,
            URL(fileURLWithPath: "\(storeURL.path)-shm"),
            URL(fileURLWithPath: "\(storeURL.path)-wal")
        ]

        for url in sidecarURLs {
            try? fileManager.removeItem(at: url)
        }
    }
}

//
//  CountieApp.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftUI
import SwiftData
import WidgetKit

@main
struct CountieApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var store: CountdownStore
    @StateObject private var modalStore: ModalStore
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        _store = StateObject(wrappedValue: CountdownStore(context: NomaModelContainer.sharedModelContainer.mainContext))
        _modalStore = StateObject(wrappedValue: ModalStore())
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasCompletedOnboarding {
                    ContentView()
                } else {
                    OnboardingFlowView(mode: .firstLaunch) {
                        hasCompletedOnboarding = true
                    }
                }
            }
            .environmentObject(store)
            .environmentObject(modalStore)
            .onAppear{
                store.fetchCountdowns()
            }
            .onOpenURL { url in
                print("Opened with URL: \(url)")
                print("Url scheme: \(url.scheme ?? "nil")")
                print("Url path: \(url.path)")
                print("Url path components: \(url.pathComponents)")


                // Deep link format: countie://countdown/<UUID>
                let pathComponents = url.pathComponents
                if url.scheme == "countie" && pathComponents.count == 2 && pathComponents[0] == "/" {
                    let uuidString = pathComponents[1]
                    if let uuid = UUID(uuidString: uuidString) {
                        // Search for countdown in store
                        if let found = store.countdowns.first(where: { $0.id == uuid }) {
                            modalStore.isSelectedCountdown = found

                            print("Countdown found: \(found.name)")
                        } else {
                            // Optionally handle not found
                            modalStore.isSelectedCountdown = nil

                            print("Countdown with UUID \(uuid) not found.")
                        }
                    } else {
                        // Optionally handle invalid UUID

                        modalStore.isSelectedCountdown = nil
                        print("Invalid UUID string: \(uuidString)")
                    }
                }
            }
            .animation(.easeInOut, value: hasCompletedOnboarding)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.syncCountdownsWithEvents()
            }
        }
        .modelContainer(NomaModelContainer.sharedModelContainer)
    }
}

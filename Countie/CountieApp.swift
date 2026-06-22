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
                openPendingCountdownIfNeeded()
            }
            .onOpenURL { url in
                openDeepLink(url)
            }
            .animation(.easeInOut, value: hasCompletedOnboarding)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                store.syncCountdownsWithEvents()
                openPendingCountdownIfNeeded()
            }
        }
        .modelContainer(NomaModelContainer.sharedModelContainer)
    }

    private func openDeepLink(_ url: URL) {
        // Deep link format: countie://countdown/<UUID>
        let pathComponents = url.pathComponents
        guard url.scheme == "countie",
              pathComponents.count == 2,
              pathComponents[0] == "/",
              let uuid = UUID(uuidString: pathComponents[1])
        else {
            return
        }

        openCountdown(id: uuid)
    }

    private func openPendingCountdownIfNeeded() {
        guard let uuid = AppIntentNavigationStore.consumePendingCountdownID() else {
            return
        }

        openCountdown(id: uuid)
    }

    private func openCountdown(id: UUID) {
        print("Opening countdown \(id.uuidString)")
        store.fetchCountdowns()
        
        if let countdown = store.countdowns.first(where: { $0.id == id }) {
            modalStore.isSelectedCountdown = countdown
            return;
        }
        
        print("No matching countdown found. Not opening.")
    }
}

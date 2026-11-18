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
    @StateObject private var countdownStore: CountdownStore
    @StateObject private var sheetStore: SheetStore
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        _countdownStore = StateObject(wrappedValue: CountdownStore(context: CountieModelContainer.sharedModelContainer.mainContext))
        _sheetStore = StateObject(wrappedValue: SheetStore())
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
            .environmentObject(countdownStore)
            .environmentObject(sheetStore)
            .onAppear{
                countdownStore.fetchCountdowns()
                openPendingCountdownIfNeeded()
            }
            .onOpenURL { url in
                openDeepLink(url)
            }
            .animation(.easeInOut, value: hasCompletedOnboarding)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                countdownStore.syncCountdownsWithEvents()
                openPendingCountdownIfNeeded()
            }
        }
        .modelContainer(CountieModelContainer.sharedModelContainer)
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
        countdownStore.fetchCountdowns()
        
        if let countdown = countdownStore.countdowns.first(where: { $0.id == id }) {
            sheetStore.isSelectedCountdown = countdown
            return;
        }
        
        print("No matching countdown found. Not opening.")
    }
}

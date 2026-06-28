//
//  CountieShortcuts.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/26.
//

import AppIntents

public struct CountieShortcuts: AppShortcutsProvider {
    public static var shortcutTileColor: ShortcutTileColor = .blue

    public static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateCountdownIntent(),
            phrases: [
                "Create a countdown in \(.applicationName)",
                "Add a countdown in \(.applicationName)",
                "Start a countdown in \(.applicationName)"
            ],
            shortTitle: "Create Countdown",
            systemImageName: "calendar.badge.plus"
        )

        AppShortcut(
            intent: OpenCountdownIntent(),
            phrases: [
                "Open \(\.$target) in \(.applicationName)",
                "Show \(\.$target) in \(.applicationName)",
                "Open a countdown in \(.applicationName)",
                "Show a countdown in \(.applicationName)"
            ],
            shortTitle: "Open Countdown",
            systemImageName: "calendar"
        )

        AppShortcut(
            intent: ShowNextCountdownIntent(),
            phrases: [
                "Show my next countdown in \(.applicationName)",
                "What's my next countdown in \(.applicationName)"
            ],
            shortTitle: "Next Countdown",
            systemImageName: "calendar.badge.clock"
        )

//        AppShortcut(
//            intent: DeleteCountdownIntent(),
//            phrases: [
//                "Delete \(\.$countdown) in \(.applicationName)",
//                "Remove \(\.$countdown) in \(.applicationName)",
//                "Delete a countdown in \(.applicationName)",
//                "Remove a countdown in \(.applicationName)"
//            ],
//            shortTitle: "Delete Countdown",
//            systemImageName: "trash"
//            
//        )
    }
}

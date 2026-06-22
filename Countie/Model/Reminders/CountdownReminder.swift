//
//  CountdownReminder.swift
//  Countie
//
//  Created by Nabil Ridhwan on 12/11/24.
//

import Foundation
import SwiftData

enum CountdownReminderPreset: CaseIterable, Identifiable {
    case atTimeOfEvent
    case fiveMinutes
    case tenMinutes
    case fifteenMinutes
    case thirtyMinutes
    case oneHour
    case twoHours
    case oneDay
    case twoDays

    var id: Int { secondsBeforeEvent }

    var secondsBeforeEvent: Int {
        switch self {
        case .atTimeOfEvent: return 0
        case .fiveMinutes: return 5 * 60
        case .tenMinutes: return 10 * 60
        case .fifteenMinutes: return 15 * 60
        case .thirtyMinutes: return 30 * 60
        case .oneHour: return 60 * 60
        case .twoHours: return 2 * 60 * 60
        case .oneDay: return 24 * 60 * 60
        case .twoDays: return 2 * 24 * 60 * 60
        }
    }

    var title: String {
        switch self {
        case .atTimeOfEvent: return "At time of event"
        case .fiveMinutes: return "5 minutes before"
        case .tenMinutes: return "10 minutes before"
        case .fifteenMinutes: return "15 minutes before"
        case .thirtyMinutes: return "30 minutes before"
        case .oneHour: return "1 hour before"
        case .twoHours: return "2 hours before"
        case .oneDay: return "1 day before"
        case .twoDays: return "2 days before"
        }
    }

    static func matching(secondsBeforeEvent: Int) -> CountdownReminderPreset? {
        self.allCases.first { $0.secondsBeforeEvent == secondsBeforeEvent }
    }
}

struct CountdownReminderDraft: Hashable, Identifiable {
    var id: UUID = UUID()
    var secondsBeforeEvent: Int
    var customLabel: String?

    var title: String {
        if let customLabel, !customLabel.isEmpty {
            return customLabel
        }

        return CountdownReminderPreset.matching(secondsBeforeEvent: secondsBeforeEvent)?.title
            ?? Self.fallbackLabel(for: secondsBeforeEvent)
    }

    static func fallbackLabel(for secondsBeforeEvent: Int) -> String {
        if secondsBeforeEvent == 0 {
            return "At time of event"
        }

        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = secondsBeforeEvent >= 86_400 ? [.day, .hour, .minute] : [.hour, .minute]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2

        let relative = formatter.string(from: TimeInterval(secondsBeforeEvent)) ?? "\(secondsBeforeEvent) seconds"
        return "\(relative) before"
    }

    static func fromModel(_ reminder: CountdownReminder) -> CountdownReminderDraft {
        CountdownReminderDraft(
            id: reminder.id,
            secondsBeforeEvent: reminder.secondsBeforeEvent,
            customLabel: reminder.customLabel
        )
    }
}

@Model
final class CountdownReminder {
    @Attribute(.unique) var id: UUID = UUID()
    @Attribute var secondsBeforeEvent: Int
    @Attribute var customLabel: String?
    @Attribute var createdAt: Date = Date()

    @Relationship var countdown: CountdownItem?

    init(secondsBeforeEvent: Int, customLabel: String? = nil) {
        self.secondsBeforeEvent = secondsBeforeEvent
        self.customLabel = customLabel
    }

    var title: String {
        CountdownReminderDraft.fromModel(self).title
    }

    var triggerDate: Date? {
        guard let countdown else { return nil }
        return countdown.date.addingTimeInterval(TimeInterval(-secondsBeforeEvent))
    }
}

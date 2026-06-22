import Foundation
import SwiftData
import UserNotifications

struct CountdownReminderNotificationRequest: Sendable {
    let reminderID: UUID
    let secondsBeforeEvent: Int
    let title: String
}

enum NotificationPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case provisional
    case ephemeral

    var isAuthorized: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}

enum CountdownReminderScheduler {
    static let notificationCategoryIdentifier = "countdown-reminder"

    static func notificationPermissionStatus() async -> NotificationPermissionStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return NotificationPermissionStatus(settings.authorizationStatus)
    }

    static func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let status = await notificationPermissionStatus()

        switch status {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        }
    }

    static func snapshot(for countdown: CountdownItem) -> [CountdownReminderNotificationRequest] {
        countdown.reminderDrafts.map { draft in
            CountdownReminderNotificationRequest(
                reminderID: draft.id,
                secondsBeforeEvent: draft.secondsBeforeEvent,
                title: draft.title
            )
        }
    }

    static func syncNotifications(
        countdownID: UUID,
        countdownName: String,
        eventDate: Date,
        reminders: [CountdownReminderNotificationRequest]
    ) async {
        await removeNotifications(for: countdownID)

        guard !reminders.isEmpty else { return }
        let center = UNUserNotificationCenter.current()

        let granted = await requestNotificationPermission()
        guard granted else { return }

        let status = await notificationPermissionStatus()
        switch status {
        case .authorized, .provisional, .ephemeral:
            break
        case .notDetermined, .denied:
            return
        }

        for reminder in reminders {
            let triggerDate = eventDate.addingTimeInterval(TimeInterval(-reminder.secondsBeforeEvent))
            guard triggerDate > .now else { continue }

            let content = UNMutableNotificationContent()
            content.title = countdownName
            content.body = reminder.secondsBeforeEvent == 0
                ? "Your countdown has reached its event time."
                : "Reminder: \(reminder.title)."
            content.sound = .default
            content.categoryIdentifier = notificationCategoryIdentifier

            let triggerComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: triggerDate
            )

            let request = UNNotificationRequest(
                identifier: notificationIdentifier(countdownID: countdownID, reminderID: reminder.reminderID),
                content: content,
                trigger: UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            )

            try? await center.add(request)
        }
    }

    static func syncNotifications(for countdown: CountdownItem) async {
        await syncNotifications(
            countdownID: countdown.id,
            countdownName: countdown.name,
            eventDate: countdown.date,
            reminders: snapshot(for: countdown)
        )
    }

    static func syncAllNotifications(in countdowns: [CountdownItem]) async {
        let snapshots = countdowns.map {
            (
                id: $0.id,
                name: $0.name,
                date: $0.date,
                reminders: snapshot(for: $0)
            )
        }

        for countdown in snapshots {
            await syncNotifications(
                countdownID: countdown.id,
                countdownName: countdown.name,
                eventDate: countdown.date,
                reminders: countdown.reminders
            )
        }
    }

    static func removeNotifications(for countdownID: UUID) async {
        let center = UNUserNotificationCenter.current()
        let pendingRequests = await center.pendingNotificationRequests()
        let identifiers = pendingRequests
            .map(\.identifier)
            .filter { $0.hasPrefix(notificationPrefix(for: countdownID)) }

        guard !identifiers.isEmpty else { return }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    static func removeNotifications(for countdown: CountdownItem) async {
        await removeNotifications(for: countdown.id)
    }

    private static func notificationIdentifier(countdownID: UUID, reminderID: UUID) -> String {
        "\(notificationPrefix(for: countdownID))\(reminderID.uuidString)"
    }

    private static func notificationPrefix(for countdownID: UUID) -> String {
        "countdown-reminder.\(countdownID.uuidString)."
    }
}

extension UNUserNotificationCenter {
    fileprivate func notificationSettings() async -> UNNotificationSettings {
        await withCheckedContinuation { continuation in
            getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }

    fileprivate func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { continuation in
            getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }

    fileprivate func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            add(request) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}

private extension NotificationPermissionStatus {
    init(_ authorizationStatus: UNAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            self = .notDetermined
        case .denied:
            self = .denied
        case .authorized:
            self = .authorized
        case .provisional:
            self = .provisional
        case .ephemeral:
            self = .ephemeral
        @unknown default:
            self = .denied
        }
    }
}

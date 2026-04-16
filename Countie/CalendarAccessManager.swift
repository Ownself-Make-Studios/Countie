//
//  CalendarAccessManager.swift
//  Countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit

enum CalendarPermissionStatus: Equatable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case writeOnly

    var isAuthorized: Bool {
        switch self {
        case .authorized:
            return true
        case .notDetermined, .denied, .restricted, .writeOnly:
            return false
        }
    }
}

struct CalendarAccessManager: Observable {
    static var store = EKEventStore()
    private var hasAccess = false

    static func permissionStatus() -> CalendarPermissionStatus {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            return .notDetermined
        case .fullAccess:
            return .authorized
        case .writeOnly:
            return .writeOnly
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        @unknown default:
            return .denied
        }
    }

    static func requestPermission() async -> Bool {
        let status = permissionStatus()

        switch status {
        case .authorized:
            return true
        case .denied, .restricted, .writeOnly:
            return false
        case .notDetermined:
            do {
                let granted = try await store.requestFullAccessToEvents()
                if granted {
                    print("[CALENDARACCESSMANAGER] Access granted")
                } else {
                    print("[CALENDARACCESSMANAGER] Access denied")
                }
                return granted
            } catch {
                print("[CALENDARACCESSMANAGER] Permission request failed: \(error.localizedDescription)")
                return false
            }
        }
    }

    static func event(with identifier: String) -> EKEvent? {
        return store.event(withIdentifier: identifier)
    }
    
//    static private var eventStoreChangedHandler: (() -> Void)?
//    static private var observer: NSObjectProtocol?
//    
//    static func observeEventStoreChanges(_ handler: @escaping () -> Void) {
//        // Remove previous observer if any
//        if let observer = observer {
//            NotificationCenter.default.removeObserver(observer)
//        }
//        eventStoreChangedHandler = handler
//        observer = NotificationCenter.default.addObserver(forName: .EKEventStoreChanged, object: store, queue: .main) { _ in
//            handler()
//        }
//    }
//    
//    static func stopObservingEventStoreChanges() {
//        if let observer = observer {
//            NotificationCenter.default.removeObserver(observer)
//            Self.observer = nil
//            eventStoreChangedHandler = nil
//        }
//    }
}

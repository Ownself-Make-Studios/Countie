//
//  CalendarAccessManager.swift
//  Countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit

struct CalendarAccessManager: Observable {
    static var store = EKEventStore()
    private var hasAccess = false
    
    static func requestPermission() {
        store.requestFullAccessToEvents { granted, error in
            if granted {
                print("[CALENDARACCESSMANAGER] Access granted")
            } else {
                print("[CALENDARACCESSMANAGER] Access denied")
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

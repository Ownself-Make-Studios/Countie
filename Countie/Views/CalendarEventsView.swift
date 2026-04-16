//
//  CalendarEventsView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import SwiftUI
import EventKit

struct CalendarEventsView: View {
    @State private var events: [EKEvent] = []
    @State private var calendars: [EKCalendar] = []
    var onSelectEvent: ((EKEvent) -> Void)?
    
    @State private var selectedCalendarID: String? = nil
    @State private var searchText: String = ""
    
    var filteredEvents: [EKEvent] {
        events.filter { event in
            (selectedCalendarID == nil || event.calendar.calendarIdentifier == selectedCalendarID) &&
            (searchText.isEmpty || event.title.localizedCaseInsensitiveContains(searchText))
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Event list
            if filteredEvents.isEmpty {
                ContentUnavailableView {
                    Label("No Calendar Events", systemImage: "calendar")
                } description: {
                    Text("There are no calendar events available. Please check your calendar settings.")
                }
            } else {
                List(filteredEvents, id: \.eventIdentifier) { event in
                    NavigationLink {
                        AddCountdownView(
                            name: event.title,
                            countdownDate: event.startDate,
                            hasTime: !event.isAllDay,
                            linkedEvent: event,
                            onAdd: {
                                onSelectEvent?(event)
                            },
                        )
                    } label: {
                        HStack{
                            Circle()
                                .fill(Color(event.calendar.cgColor))
                                .frame(width: 10, height: 10)
                            VStack(alignment: .leading){
                                Text(event.title)
                                    .font(.headline)
                                Text(event.startDate.formatted())
                                    .font(.subheadline)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Picker("Calendar", selection: $selectedCalendarID) {
                        Text("All").tag(String?.none)
                        ForEach(calendars, id: \.calendarIdentifier) { calendar in
                            Text(calendar.title).tag(Optional(calendar.calendarIdentifier))
                        }
                    }
                } label: {
                    Image(
                        systemName:
                            selectedCalendarID == nil
                                ? "line.3.horizontal.decrease.circle"
                                : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search events")
        .task {
            let granted = await CalendarAccessManager.requestPermission()
            guard granted else {
                calendars = []
                events = []
                return
            }

            calendars = CalendarAccessManager.store.calendars(for: .event)
            let predicate = CalendarAccessManager.store.predicateForEvents(withStart: Date.now, end: Date.distantFuture, calendars: nil)
            events = CalendarAccessManager.store.events(matching: predicate)
        }
    }
}

#Preview {
    CalendarEventsView()
}

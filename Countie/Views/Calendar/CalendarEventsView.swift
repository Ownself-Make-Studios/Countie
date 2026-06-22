//
//  CalendarEventsView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 2/11/24.
//

import EventKit
import SwiftUI
import UIKit

private struct SelectedCalendarEvent: Identifiable, Hashable {
    let id = UUID()
    let event: EKEvent

    static func == (lhs: SelectedCalendarEvent, rhs: SelectedCalendarEvent) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

private struct CalendarFilterChip: View {
    let title: String
    let color: Color?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let color {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                }

                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor.opacity(0.16) : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.accentColor.opacity(0.4) : Color.clear, lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct CalendarEventRow: View {
    let event: EKEvent

    private var secondaryText: String {
        if event.isAllDay {
            return "All-day"
        }

        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: event.startDate, to: event.endDate)
    }

    private var isRecurring: Bool {
        event.isDetached || event.occurrenceDate != nil || !(event.recurrenceRules ?? []).isEmpty
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color(event.calendar.cgColor))
                .frame(width: 10, height: 10)
                .padding(.top, 6)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if isRecurring {
                        Image(systemName: "repeat")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                }

                Text(secondaryText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(event.calendar.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 12)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .padding(.top, 4)
        }
        .contentShape(Rectangle())
    }
}

private struct EventCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    let visibleMonth: Date
    let onVisibleMonthChange: (Date) -> Void

    private let calendar = Calendar.autoupdatingCurrent

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = calendar
        calendarView.locale = .autoupdatingCurrent
        calendarView.delegate = context.coordinator

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        selection.setSelected(normalizedComponents(for: selectedDate), animated: false)
        calendarView.visibleDateComponents = visibleMonthComponents(for: visibleMonth)

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        context.coordinator.parent = self

        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate,
           selection.selectedDate != normalizedComponents(for: selectedDate) {
            selection.setSelected(normalizedComponents(for: selectedDate), animated: true)
        }

        if uiView.visibleDateComponents != visibleMonthComponents(for: visibleMonth) {
            uiView.visibleDateComponents = visibleMonthComponents(for: visibleMonth)
        }
    }

    private func normalizedComponents(for date: Date) -> DateComponents {
        calendar.dateComponents([.year, .month, .day], from: date)
    }

    private func visibleMonthComponents(for date: Date) -> DateComponents {
        calendar.dateComponents([.year, .month], from: date)
    }

    final class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: EventCalendarView
        private let calendar = Calendar.autoupdatingCurrent

        init(parent: EventCalendarView) {
            self.parent = parent
        }

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents,
                  let date = calendar.date(from: dateComponents) else { return }
            parent.selectedDate = date
        }

        func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
            guard let visibleDate = calendar.date(from: calendarView.visibleDateComponents) else { return }
            parent.onVisibleMonthChange(visibleDate)
        }
    }
}

struct CalendarEventsView: View {
    @State private var browseEventsForSelectedDate: [EKEvent] = []
    @State private var calendars: [EKCalendar] = []
    @State private var selectedDate = Date.now
    @State private var visibleMonth = Date.now
    @State private var selectedCalendarIDs: Set<String> = []
    @State private var selectedEvent: SelectedCalendarEvent?
    @State private var didLoad = false
    @State private var hasPermission = true

    var onSelectEvent: ((EKEvent) -> Void)?

    private let calendar = Calendar.autoupdatingCurrent

    private var allCalendarsSelected: Bool {
        !calendars.isEmpty && selectedCalendarIDs.count == calendars.count
    }

    private var browseEvents: [EKEvent] {
        CalendarEventLinkMatcher.sortForDateList(browseEventsForSelectedDate)
    }

    private let emptyStateTitle = "No Events on This Date"
    private let emptyStateDescription = "Choose another date or adjust the calendar filters to see events."

    var body: some View {
        Group {
            if hasPermission {
                content
            } else {
                ContentUnavailableView {
                    Label("Calendar Access Needed", systemImage: "calendar.badge.exclamationmark")
                } description: {
                    Text("Countie needs full calendar access to browse and import events.")
                }
            }
        }
        .navigationTitle("Add from Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedEvent) { selection in
            AddCountdownView(
                name: selection.event.title,
                countdownDate: selection.event.startDate,
                hasTime: !selection.event.isAllDay,
                linkedEvent: selection.event,
                onAdd: {
                    onSelectEvent?(selection.event)
                }
            )
        }
        // Search is intentionally disabled for now until the broader EventKit query
        // path is made reliable for subscribed calendars and holiday feeds.
        // .searchable(text: $searchText, placement: .toolbar, prompt: "Search calendar history")
        .task {
            guard !didLoad else { return }
            didLoad = true
            visibleMonth = selectedDate
            await loadInitialData()
        }
        .onChange(of: selectedDate) { _, _ in
            Task { await loadBrowseEvents() }
        }
    }

    private var content: some View {
        VStack(spacing: 14) {
            browseContent
        }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CalendarFilterChip(
                    title: "All",
                    color: nil,
                    isSelected: allCalendarsSelected,
                    action: toggleAllCalendars
                )

                ForEach(calendars, id: \.calendarIdentifier) { calendar in
                    CalendarFilterChip(
                        title: calendar.title,
                        color: Color(calendar.cgColor),
                        isSelected: selectedCalendarIDs.contains(calendar.calendarIdentifier),
                        action: {
                            toggleCalendarSelection(calendar.calendarIdentifier)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
        .padding(.top, 4)
    }

    private var browseContent: some View {
        VStack(spacing: 12) {
            EventCalendarView(
                selectedDate: $selectedDate,
                visibleMonth: visibleMonth,
                onVisibleMonthChange: { newVisibleMonth in
                    visibleMonth = newVisibleMonth
                }
            )
            .frame(height: 320)
            .clipped()
            .padding(.horizontal)

            filterChips

            if browseEvents.isEmpty {
                Spacer(minLength: 0)
                ContentUnavailableView {
                    Label(emptyStateTitle, systemImage: "calendar")
                } description: {
                    Text(emptyStateDescription)
                }
                Spacer(minLength: 0)
            } else {
                List(browseEvents, id: \.eventIdentifier) { event in
                    Button {
                        selectedEvent = SelectedCalendarEvent(event: event)
                    } label: {
                        CalendarEventRow(event: event)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
    }

    @MainActor
    private func loadInitialData() async {
        let granted = await CalendarAccessManager.requestPermission()
        hasPermission = granted

        guard granted else {
            calendars = []
            selectedCalendarIDs = []
            browseEventsForSelectedDate = []
            return
        }

        calendars = CalendarAccessManager.store.calendars(for: .event)
        selectedCalendarIDs = Set(calendars.map(\.calendarIdentifier))
        await loadBrowseEvents()
    }

    @MainActor
    private func loadBrowseEvents() async {
        guard hasPermission else { return }

        let startDate = CalendarAccessManager.startOfDay(for: selectedDate)
        let endDate = CalendarAccessManager.endOfDay(for: selectedDate)
        browseEventsForSelectedDate = CalendarAccessManager.events(
            from: startDate,
            to: endDate,
            calendarIDs: selectedCalendarIDs
        )
    }

    private func toggleAllCalendars() {
        if allCalendarsSelected {
            selectedCalendarIDs = []
        } else {
            selectedCalendarIDs = Set(calendars.map(\.calendarIdentifier))
        }

        refreshEventsForCurrentMode()
    }

    private func toggleCalendarSelection(_ calendarID: String) {
        if selectedCalendarIDs.contains(calendarID) {
            selectedCalendarIDs.remove(calendarID)
        } else {
            selectedCalendarIDs.insert(calendarID)
        }

        refreshEventsForCurrentMode()
    }

    private func refreshEventsForCurrentMode() {
        Task {
            await loadBrowseEvents()
        }
    }
}

#Preview {
    NavigationStack {
        CalendarEventsView()
    }
}

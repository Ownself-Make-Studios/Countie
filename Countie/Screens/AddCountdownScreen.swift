//
//  AddCountdownView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import EventKit
import SwiftUI
import SwiftData
import WidgetKit
import CoreSpotlight

private struct IconPickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var selectedIconName: String
    @State private var searchText = ""

    private var filteredIcons: [CountdownEventIcon.Entry] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return CountdownEventIcon.allEntries }
        return CountdownEventIcon.allEntries.filter { $0.matches(trimmed) }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 88, maximum: 120), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(filteredIcons) { icon in
                        Button {
                            selectedIconName = icon.symbolName
                            dismiss()
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: icon.symbolName)
                                    .font(.title2.weight(.semibold))
                                    .frame(width: 28, height: 28)

                                Text(icon.label)
                                    .font(.caption.weight(.semibold))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)

//                                Text(icon.symbolName)
//                                    .font(.caption2)
//                                    .foregroundStyle(.secondary)
//                                    .multilineTextAlignment(.center)
//                                    .lineLimit(2)
                            }
                            .foregroundStyle(selectedIconName == icon.symbolName ? .white : .primary)
                            .frame(maxWidth: .infinity, minHeight: 108)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(selectedIconName == icon.symbolName ? Color.accentColor : Color(.secondarySystemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search icons, like birthday or travel")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct CountdownPreviewSection: View {
    let iconName: String
    let color: Color

    var body: some View {
        HStack {
            Spacer()
            CircularEventIconView(
                iconName: iconName,
                tint: color,
                progress: 0.75,
                showProgress: false,
                width: 100,
                iconSize: 42
            )
            Spacer()
        }
        .listRowBackground(Color.clear)
    }
}

private struct AppearanceSection: View {
    @Binding var color: CountdownEventColor

    let iconName: String
    let onChooseIcon: () -> Void

    private let colorColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    private var selectedIconLabel: String {
        CountdownEventIcon.allEntries.first(where: { $0.symbolName == iconName })?.label ?? iconName
    }

    var body: some View {
        Section("Appearance") {
            Button(action: onChooseIcon) {
                HStack(spacing: 12) {
                    Image(systemName: iconName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(color.color)
                        .frame(width: 36, height: 36)
                        .background(color.color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Icon")
                            .foregroundStyle(.primary)
                        Text("Selected: \(selectedIconLabel)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)
            
                          ScrollView(.horizontal, showsIndicators: false){
                    LazyHStack(spacing: 12) {
                        
                    ForEach(CountdownEventColor.allCases) { option in
                        Button {
                            color = option
                        } label: {
                            Circle()
                                .fill(option.color)
                                .frame(width: 34, height: 34)
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.title)
                    }
                
                    }
                }


        }
    }
}

private struct LinkedCalendarEventSection: View {
    let event: EKEvent
    let onUnlink: () -> Void

    var body: some View {
        Section("Calendar Event") {
            HStack {
                Circle()
                    .fill(Color(event.calendar.cgColor))
                    .frame(width: 10, height: 10)
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                    Text(event.startDate.formatted())
                        .font(.subheadline)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Button("Unlink Event", action: onUnlink)

                Text(
                    "Unlinking the event will remove the link to the calendar event, and the countdown will not update if the event changes."
                )
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct CountdownSettingsSection: View {
    @Binding var countdownDate: Date
    @Binding var countSinceDate: Date

    let isDateEditingDisabled: Bool

    var body: some View {
        Section("Date & Time") {
            DatePicker(
                "Date & Time",
                selection: $countdownDate,
                in: Date.now...,
                displayedComponents: [.date, .hourAndMinute],
            )
            .datePickerStyle(.graphical)
            .disabled(isDateEditingDisabled)

//            VStack(alignment: .leading, spacing: 10) {
//                DatePicker(
//                    "Countdown Start Date",
//                    selection: $countSinceDate,
//                    in: ...countdownDate,
//                    displayedComponents:
//                        [.date, .hourAndMinute]
//                )
//
//                Text("Progress starts from this date.")
//                    .font(.footnote)
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.leading)
//            }
        }
    }
}

struct AddCountdownView: View {
    @EnvironmentObject private var countdownStore: CountdownStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let onAdd: (() -> Void)?
    private let countdownToEdit: CountdownItem?

    @State private var iconName: String
    @State private var color: CountdownEventColor
    @State private var name: String
    @State private var countdownDate: Date
    @State private var countSinceDate: Date
    @State private var linkedEvent: EKEvent?

    @State private var showIconPicker = false

    private var isSubmitDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var navigationTitle: String {
        countdownToEdit == nil ? "New Countdown" : "Edit Countdown"
    }

    private var submitButtonTitle: String {
        countdownToEdit == nil ? "Add" : "Save"
    }

    private var isDateEditingDisabled: Bool {
        linkedEvent != nil
    }

    init(countdownToEdit: CountdownItem? = nil, onAdd: (() -> Void)? = nil) {
        self.onAdd = onAdd
        self.countdownToEdit = countdownToEdit

        if let countdownToEdit {
            var resolvedLinkedEvent: EKEvent?
            if countdownToEdit.calendarEventIdentifier != nil
                || countdownToEdit.calendarOccurrenceDate != nil {
                resolvedLinkedEvent = CalendarAccessManager.resolveEvent(for: countdownToEdit)
            }

            _iconName = State(initialValue: countdownToEdit.resolvedIconName)
            _color = State(initialValue: countdownToEdit.color)
            _name = State(initialValue: countdownToEdit.name)
            _countdownDate = State(initialValue: countdownToEdit.date)
            _countSinceDate = State(initialValue: countdownToEdit.countSince)
            _linkedEvent = State(initialValue: resolvedLinkedEvent)
        } else {
            _iconName = State(initialValue: CountdownEventIcon.default)
            _color = State(initialValue: .blue)
            _name = State(initialValue: "")
            _countdownDate = State(
                initialValue: Calendar.current.startOfDay(for: Date.now)
                    .addingTimeInterval(7 * 24 * 60 * 60)
            )
            _countSinceDate = State(initialValue: Date.now)
            _linkedEvent = State(initialValue: nil)
        }
    }

    init(
        name: String = "",
        countdownDate: Date = Calendar.current.startOfDay(for: Date.now),
        linkedEvent: EKEvent? = nil,
        onAdd: (() -> Void)? = nil
    ) {
        self.onAdd = onAdd
        self.countdownToEdit = nil
        _iconName = State(initialValue: CountdownEventIcon.default)
        _color = State(initialValue: .blue)
        _name = State(initialValue: name)
        _countdownDate = State(initialValue: countdownDate)
        _countSinceDate = State(initialValue: Date.now)
        _linkedEvent = State(initialValue: linkedEvent)
    }

    var body: some View {
        NavigationStack {
            Form {
//                CountdownPreviewSection(iconName: iconName, color: color)

                Section("Countdown Name") {
                    TextField("Graduation, Anniversary, etc.", text: $name)
                }

                AppearanceSection(
                    color: $color,
                    iconName: iconName,
                    onChooseIcon: presentIconPicker
                )

                if let linkedEvent {
                    LinkedCalendarEventSection(
                        event: linkedEvent,
                        onUnlink: unlinkEvent
                    )
                }

                CountdownSettingsSection(
                    countdownDate: $countdownDate,
                    countSinceDate: $countSinceDate,
                    isDateEditingDisabled: isDateEditingDisabled
                )

            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(submitButtonTitle, action: handleSaveItem)
                        .disabled(isSubmitDisabled)
                }
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerSheet(selectedIconName: $iconName)
        }
    }

    private func handleSaveItem() {
        let item: CountdownItem;
        
        if let editing = countdownToEdit {
            editing.iconName = iconName
            editing.color = color
            editing.name = name
            editing.date = countdownDate
            editing.countSince = countSinceDate

            applyLinkedEventMetadata(from: linkedEvent, to: editing)

            try? modelContext.save()
            item = editing
        } else {
            item = CountdownItem(
                name: name,
                date: countdownDate,
                iconName: iconName,
                color: color
            )
            item.countSince = countSinceDate

            applyLinkedEventMetadata(from: linkedEvent, to: item)

            modelContext.insert(item)
            try? modelContext.save()
        }
        
        WidgetCenter.shared.reloadAllTimelines()
        CountdownSearchIndex.index(item)
        CountieShortcuts.updateAppShortcutParameters()
        countdownStore.fetchCountdowns()
        dismiss()
        onAdd?()
    }

    private func applyLinkedEventMetadata(
        from event: EKEvent?,
        to item: CountdownItem
    ) {
        guard let event else {
            item.calendarEventIdentifier = nil
            item.calendarSeriesIdentifier = nil
            item.calendarOccurrenceDate = nil
            item.calendarRecurrenceImportScope = nil
            return
        }

        let linkDetails = CalendarEventLinkDetails(event: event)
        item.calendarEventIdentifier = linkDetails.eventIdentifier
        item.calendarSeriesIdentifier = linkDetails.seriesIdentifier
        item.calendarOccurrenceDate = linkDetails.occurrenceDate
        item.calendarRecurrenceImportScope = linkDetails.importScope
    }

    private func presentIconPicker() {
        showIconPicker = true
    }

    private func unlinkEvent() {
        linkedEvent = nil
    }

}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
}

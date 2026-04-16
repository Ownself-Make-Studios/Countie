//
//  AddCountdownView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import EventKit
import SwiftUI
import WidgetKit

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

                                Text(icon.symbolName)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
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

private struct CustomReminderSheet: View {
    @Environment(\.dismiss) private var dismiss

    let eventDate: Date
    let onSave: (CountdownReminderDraft) -> Void

    @State private var reminderDate: Date

    init(eventDate: Date, onSave: @escaping (CountdownReminderDraft) -> Void) {
        self.eventDate = eventDate
        self.onSave = onSave

        let minimumDate = Date.now
        let proposedDate = minimumDate.addingTimeInterval(5 * 60)
        _reminderDate = State(initialValue: min(eventDate, proposedDate))
    }

    private var boundedReminderDate: Date {
        min(max(reminderDate, Date.now), eventDate)
    }

    private var secondsBeforeEvent: Int {
        max(Int(eventDate.timeIntervalSince(boundedReminderDate)), 0)
    }

    private var draft: CountdownReminderDraft {
        CountdownReminderDraft(
            secondsBeforeEvent: secondsBeforeEvent,
            customLabel: CountdownReminderDraft.fallbackLabel(for: secondsBeforeEvent)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker(
                    "Reminder Date & Time",
                    selection: $reminderDate,
                    in: Date.now...eventDate,
                    displayedComponents: [.date, .hourAndMinute]
                )

                Text(draft.title)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Custom Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        onSave(draft)
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: reminderDate) { _, newValue in
            reminderDate = min(max(newValue, Date.now), eventDate)
        }
    }
}

private struct CountdownPreviewSection: View {
    let iconName: String
    let color: CountdownEventColor

    var body: some View {
        HStack {
            Spacer()
            CircularEventIconView(
                iconName: iconName,
                tint: color.color,
                progress: 0.75,
                showProgress: false,
                width: 120,
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
            VStack(alignment: .leading, spacing: 12) {
                Text("Color")
                    .font(.subheadline.weight(.medium))

                LazyVGrid(columns: colorColumns, spacing: 12) {
                    ForEach(CountdownEventColor.allCases) { option in
                        Button {
                            color = option
                        } label: {
                            Circle()
                                .fill(option.color)
                                .frame(width: 34, height: 34)
                                .overlay {
                                    if color == option {
                                        Image(systemName: "checkmark")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white)
                                    }
                                }
                                .overlay {
                                    Circle()
                                        .strokeBorder(Color.primary.opacity(color == option ? 0 : 0.12), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(option.title)
                    }
                }
            }
            .padding(.vertical, 4)

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
                        Text(selectedIconLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
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
    @Binding var hasTime: Bool
    @Binding var countdownDate: Date
    @Binding var countSinceDate: Date

    let isDateEditingDisabled: Bool

    var body: some View {
        Section("Countdown Settings") {
            Toggle("Include Time of day", isOn: $hasTime)
                .disabled(isDateEditingDisabled)

            DatePicker(
                "Countdown Target Date\(hasTime ? " & Time" : "")",
                selection: $countdownDate,
                in: Date.now...,
                displayedComponents: hasTime
                    ? [.date, .hourAndMinute] : [.date]
            )
            .disabled(isDateEditingDisabled)

            VStack(alignment: .leading, spacing: 10) {
                DatePicker(
                    "Countdown Start Date\(hasTime ? " & Time" : "")",
                    selection: $countSinceDate,
                    in: ...countdownDate,
                    displayedComponents: hasTime
                        ? [.date, .hourAndMinute] : [.date]
                )

                Text("Progress starts from this date.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
        }
    }
}

private struct ReminderSection: View {
    let reminderDrafts: [CountdownReminderDraft]
    let availablePresets: [CountdownReminderPreset]
    let onDelete: (IndexSet) -> Void
    let onTogglePreset: (CountdownReminderPreset) -> Void
    let onShowCustomReminder: () -> Void

    var body: some View {
        Section("Remind Me") {
            ForEach(reminderDrafts) { reminder in
                Text(reminder.title)
            }
            .onDelete(perform: onDelete)

            Menu {
                ForEach(availablePresets) { preset in
                    Button(preset.title) {
                        onTogglePreset(preset)
                    }
                }

                Divider()

                Button("Custom...", action: onShowCustomReminder)
            } label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
}

struct AddCountdownView: View {
    @EnvironmentObject private var store: CountdownStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    private let onAdd: (() -> Void)?
    private let countdownToEdit: CountdownItem?

    @State private var iconName = CountdownEventIcon.default
    @State private var color: CountdownEventColor = .blue
    @State private var name = ""
    @State private var countdownDate: Date = Calendar.current.startOfDay(for: Date.now)
        .addingTimeInterval(7 * 24 * 60 * 60)
    @State private var countSinceDate = Date.now
    @State private var hasTime = true
    @State private var reminderDrafts: [CountdownReminderDraft] = []

    @State private var showIconPicker = false
    @State private var linkedEvent: EKEvent? = nil
    @State private var showCustomReminderSheet = false

    private var isSubmitDisabled: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var navigationTitle: String {
        countdownToEdit == nil ? "New Countdown" : "Edit Countdown"
    }

    private var submitButtonTitle: String {
        countdownToEdit == nil ? "Add" : "Save"
    }

    private var availablePresets: [CountdownReminderPreset] {
        CountdownReminderPreset.allCases.filter { preset in
            !reminderDrafts.contains(where: { $0.secondsBeforeEvent == preset.secondsBeforeEvent })
        }
    }

    init(countdownToEdit: CountdownItem? = nil, onAdd: (() -> Void)? = nil) {
        self.countdownToEdit = countdownToEdit
        self.onAdd = onAdd
    }

    init(
        name: String = "",
        countdownDate: Date = Calendar.current.startOfDay(for: Date.now),
        hasTime: Bool = false,
        linkedEvent: EKEvent? = nil,
        onAdd: (() -> Void)? = nil
    ) {
        _name = .init(initialValue: name)
        _countdownDate = .init(initialValue: countdownDate)
        _hasTime = .init(initialValue: hasTime)
        _linkedEvent = .init(initialValue: linkedEvent)
        self.countdownToEdit = nil
        self.onAdd = onAdd
    }

    var body: some View {
        NavigationStack {
            Form {
                CountdownPreviewSection(iconName: iconName, color: color)

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
                    hasTime: $hasTime,
                    countdownDate: $countdownDate,
                    countSinceDate: $countSinceDate,
                    isDateEditingDisabled: linkedEvent != nil
                )

                ReminderSection(
                    reminderDrafts: reminderDrafts,
                    availablePresets: availablePresets,
                    onDelete: deleteReminders,
                    onTogglePreset: togglePreset,
                    onShowCustomReminder: presentCustomReminderSheet
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
        .sheet(isPresented: $showCustomReminderSheet) {
            CustomReminderSheet(eventDate: countdownDate) { draft in
                addCustomReminder(draft)
            }
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerSheet(selectedIconName: $iconName)
        }
        .onAppear(perform: loadInitialState)
        .onChange(of: hasTime) { _, newValue in
            handleTimeVisibilityChange(newValue)
        }
    }

    private func handleSaveItem() {
        let normalizedCountdownDate = hasTime
            ? countdownDate
            : Calendar.current.startOfDay(for: countdownDate)
        let normalizedCountSinceDate = hasTime
            ? countSinceDate
            : Calendar.current.startOfDay(for: countSinceDate)

        let normalizedReminders = reminderDrafts
            .filter { $0.secondsBeforeEvent >= 0 }
            .uniqued(by: \.secondsBeforeEvent)
            .sorted { $0.secondsBeforeEvent < $1.secondsBeforeEvent }

        let savedItem: CountdownItem

        if let editing = countdownToEdit {
            editing.iconName = iconName
            editing.eventColor = color
            editing.name = name
            editing.includeTime = hasTime
            editing.date = normalizedCountdownDate
            editing.countSince = normalizedCountSinceDate

            applyLinkedEventMetadata(from: linkedEvent, to: editing)

            replaceReminders(for: editing, with: normalizedReminders)
            try? modelContext.save()
            savedItem = editing
        } else {
            let item: CountdownItem = CountdownItem(
                name: name,
                includeTime: hasTime,
                date: normalizedCountdownDate,
                iconName: iconName,
                colorNameRaw: color.rawValue
            )
            item.countSince = normalizedCountSinceDate

            applyLinkedEventMetadata(from: linkedEvent, to: item)

            modelContext.insert(item)
            replaceReminders(for: item, with: normalizedReminders)
            try? modelContext.save()
            savedItem = item
        }

        let reminderRequests = CountdownReminderScheduler.snapshot(for: savedItem)
        let countdownID = savedItem.id
        let countdownName = savedItem.name
        let eventDate = savedItem.date
        Task {
            await CountdownReminderScheduler.syncNotifications(
                countdownID: countdownID,
                countdownName: countdownName,
                eventDate: eventDate,
                reminders: reminderRequests
            )
        }

        WidgetCenter.shared.reloadAllTimelines()
        store.fetchCountdowns()
        dismiss()
        onAdd?()
    }

    private func replaceReminders(for item: CountdownItem, with drafts: [CountdownReminderDraft]) {
        for existingReminder in item.reminders {
            modelContext.delete(existingReminder)
        }
        item.reminders.removeAll()

        for draft in drafts {
            let reminder = CountdownReminder(
                secondsBeforeEvent: draft.secondsBeforeEvent,
                customLabel: draft.customLabel
            )
            reminder.countdown = item
            modelContext.insert(reminder)
            item.reminders.append(reminder)
        }
    }

    private func togglePreset(_ preset: CountdownReminderPreset) {
        if let index = reminderDrafts.firstIndex(where: { $0.secondsBeforeEvent == preset.secondsBeforeEvent }) {
            reminderDrafts.remove(at: index)
        } else {
            reminderDrafts.append(
                CountdownReminderDraft(
                    secondsBeforeEvent: preset.secondsBeforeEvent,
                    customLabel: nil
                )
            )
        }

        reminderDrafts.sort { $0.secondsBeforeEvent < $1.secondsBeforeEvent }
    }

    private func addCustomReminder(_ draft: CountdownReminderDraft) {
        guard !reminderDrafts.contains(where: { $0.secondsBeforeEvent == draft.secondsBeforeEvent }) else { return }
        reminderDrafts.append(draft)
        reminderDrafts.sort { $0.secondsBeforeEvent < $1.secondsBeforeEvent }
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

    private func presentCustomReminderSheet() {
        showCustomReminderSheet = true
    }

    private func deleteReminders(at offsets: IndexSet) {
        reminderDrafts.remove(atOffsets: offsets)
    }

    private func unlinkEvent() {
        linkedEvent = nil
    }

    private func loadInitialState() {
        if let editing = countdownToEdit {
            editing.normalizeAppearance()
            iconName = editing.resolvedIconName
            color = editing.eventColor
            name = editing.name
            hasTime = editing.includeTime
            countdownDate = editing.date
            countSinceDate = editing.countSince
            reminderDrafts = editing.reminderDrafts

            if editing.calendarEventIdentifier != nil
                || editing.calendarOccurrenceDate != nil {
                linkedEvent = CalendarAccessManager.resolveEvent(for: editing)
            }
        } else {
            iconName = CountdownEventIcon.default
            color = .blue
        }
    }

    private func handleTimeVisibilityChange(_ includesTime: Bool) {
        guard !includesTime else { return }
        countdownDate = Calendar.current.startOfDay(for: countdownDate)
    }
}

#Preview {
    AddCountdownView()
        .modelContainer(for: CountdownItem.self, inMemory: true)
        .modelContainer(for: CountdownReminder.self, inMemory: true)
}

private extension Array {
    func uniqued<Value: Hashable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
        var seen: Set<Value> = []
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

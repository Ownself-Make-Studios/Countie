//
//  AddCountdownView.swift
//  noma
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import EventKit
import SwiftUI
import WidgetKit

extension UIKeyboardType {
    static let emoji = UIKeyboardType(rawValue: 124)
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

struct AddCountdownView: View {
    @EnvironmentObject var store: CountdownStore
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    var onAdd: (() -> Void)? = nil

    // Optional countdown to edit
    var countdownToEdit: CountdownItem? = nil

    @State var emoji: String = ""
    @FocusState private var emojiFieldFocused: Bool
    @State var name: String = ""
    @State var countdownDate: Date = Calendar.current.startOfDay(for: Date.now)
        .addingTimeInterval(7 * 24 * 60 * 60)
    @State var countSinceDate: Date = Date.now
    @State var hasTime: Bool = true
    @State var reminderDrafts: [CountdownReminderDraft] = []

    @State private var showEmojiPicker: Bool = false
    @State private var linkedEvent: EKEvent? = nil
    @State private var showCustomReminderSheet: Bool = false

    var isSubmitDisabled: Bool {
        name.isEmpty && emoji.isEmpty
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
        self.onAdd = onAdd
    }

    func handleSaveItem() {
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
            editing.emoji = emoji
            editing.name = name
            editing.includeTime = hasTime
            editing.date = normalizedCountdownDate
            editing.countSince = normalizedCountSinceDate

            if let event = linkedEvent {
                editing.calendarEventIdentifier = event.eventIdentifier
            } else {
                editing.calendarEventIdentifier = nil
            }

            replaceReminders(for: editing, with: normalizedReminders)
            try? modelContext.save()
            savedItem = editing
        } else {
            let item: CountdownItem = CountdownItem(
                emoji: emoji,
                name: name,
                includeTime: hasTime,
                date: normalizedCountdownDate
            )
            item.countSince = normalizedCountSinceDate

            if let event = linkedEvent {
                item.calendarEventIdentifier = event.eventIdentifier
            }

            modelContext.insert(item)
            replaceReminders(for: item, with: normalizedReminders)
            try? modelContext.save()
            savedItem = item
        }

        let reminderRequests = CountdownReminderScheduler.snapshot(for: savedItem)
        let countdownID = savedItem.id
        let countdownName = savedItem.name
        let countdownEmoji = savedItem.emoji
        let eventDate = savedItem.date
        Task {
            await CountdownReminderScheduler.syncNotifications(
                countdownID: countdownID,
                countdownName: countdownName,
                countdownEmoji: countdownEmoji,
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

    private var availablePresets: [CountdownReminderPreset] {
        CountdownReminderPreset.allCases.filter { preset in
            !reminderDrafts.contains(where: { $0.secondsBeforeEvent == preset.secondsBeforeEvent })
        }
    }

    private func addCustomReminder(_ draft: CountdownReminderDraft) {
        guard !reminderDrafts.contains(where: { $0.secondsBeforeEvent == draft.secondsBeforeEvent }) else { return }
        reminderDrafts.append(draft)
        reminderDrafts.sort { $0.secondsBeforeEvent < $1.secondsBeforeEvent }
    }

    private func removeReminder(_ draft: CountdownReminderDraft) {
        reminderDrafts.removeAll { $0.id == draft.id || $0.secondsBeforeEvent == draft.secondsBeforeEvent }
    }

    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    Spacer()
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120)
                        .overlay(
                            Group {
                                if emoji.isEmpty {
                                    Image(systemName: "face.dashed")
                                        .resizable()
                                        .frame(width: 42, height: 42)
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text(emoji)
                                        .font(.system(size: 42))
                                }
                            }
                        )
                        .onTapGesture {
                            withAnimation {
                                print("Show emoji picker")
                                emojiFieldFocused = true
                            }
                        }
                    Spacer()
                }
                .listRowBackground(Color.clear)

                Section("Countdown Name") {
                    TextField("Graduation, Anniversary, etc.", text: $name)
                }

                if let event = linkedEvent {
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

                            Button("Unlink Event") {
                                linkedEvent = nil
                            }

                            Text(
                                "Unlinking the event will remove the link to the calendar event, and the countdown will not update if the event changes."
                            )
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity)
                        }

                        //                        Toggle(
                        //                            "Update countdown when event changes",
                        //                            isOn: $updateCountdownWhenEventChanges
                        //                        )
                        //                        .disabled(true)  // Disable this for now, as we don't have the logic implemented yet

                    }
                }

                Section("Countdown Settings") {
                    Toggle("Include Time of day", isOn: $hasTime)
                        .disabled(linkedEvent != nil)

                    DatePicker(
                        "Countdown Target Date\(hasTime ? " & Time" : "")",
                        selection: $countdownDate,
                        in: Date.now...,
                        displayedComponents: hasTime
                            ? [.date, .hourAndMinute] : [.date]
                    )
                    .disabled(linkedEvent != nil)

                    VStack(alignment: .leading, spacing: 10) {

                        DatePicker(
                            "Countdown Start Date\(hasTime ? " & Time" : "")",
                            selection: $countSinceDate,
                            in: ...countdownDate,
                            displayedComponents: hasTime
                                ? [.date, .hourAndMinute] : [.date]
                        )

                        Text(
                            "Progress starts from this date."
                        )
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    }
                }

                Section("Remind Me") {
                    ForEach(reminderDrafts) { reminder in
                        Text(reminder.title)
                    }
                    .onDelete { offsets in
                        reminderDrafts.remove(atOffsets: offsets)
                    }

                    Menu {
                        ForEach(availablePresets) { preset in
                            Button(preset.title) {
                                togglePreset(preset)
                            }
                        }

                        Divider()

                        Button("Custom...") {
                            showCustomReminderSheet = true
                        }
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }

                // Keyboard for the emoji picker!
                TextField("Emoji", text: $emoji)
                    .keyboardType(.emoji!)
                    .focused($emojiFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .onChange(of: emoji) { _, newVal in
                        if !newVal.isEmpty {

                            emoji = newVal.last.map { String($0) } ?? ""
                            withAnimation {
                                emojiFieldFocused = false  // Close keyboard when emoji selected
                            }
                        }
                    }
                    .listRowBackground(Color.clear)

            }
            .navigationTitle(
                countdownToEdit == nil ? "New Countdown" : "Edit Countdown"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button(countdownToEdit == nil ? "Add" : "Save") {
                    handleSaveItem()
                }.disabled(isSubmitDisabled)
            }

        }
        .sheet(isPresented: $showCustomReminderSheet) {
            CustomReminderSheet(eventDate: countdownDate) { draft in
                addCustomReminder(draft)
            }
        }
        .onAppear {
            if let editing = countdownToEdit {
                emoji = editing.emoji ?? ""
                name = editing.name
                hasTime = editing.includeTime
                countdownDate = editing.date
                countSinceDate = editing.countSince
                reminderDrafts = editing.reminderDrafts

                if let eventIdentifier = editing.calendarEventIdentifier {
                    linkedEvent = CalendarAccessManager.event(
                        with: eventIdentifier
                    )
                }
            }
        }
        .onChange(of: hasTime) { _, newVal in
            if !newVal {
                let dateWithoutTime = Calendar.current.startOfDay(
                    for: countdownDate
                )
                countdownDate = dateWithoutTime
            }
        }
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

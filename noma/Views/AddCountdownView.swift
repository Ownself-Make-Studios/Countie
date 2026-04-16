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

    let onSave: (CountdownReminderDraft) -> Void

    @State private var days: Int = 0
    @State private var hours: Int = 0
    @State private var minutes: Int = 5

    private var totalSeconds: Int {
        (days * 24 * 60 * 60) + (hours * 60 * 60) + (minutes * 60)
    }

    private var draft: CountdownReminderDraft {
        CountdownReminderDraft(
            secondsBeforeEvent: totalSeconds,
            customLabel: CountdownReminderDraft.fallbackLabel(for: totalSeconds)
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Days", selection: $days) {
                    ForEach(0..<31, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }

                Picker("Hours", selection: $hours) {
                    ForEach(0..<24, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }

                Picker("Minutes", selection: $minutes) {
                    ForEach(0..<60, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }

                if totalSeconds > 0 {
                    Text(draft.title)
                        .foregroundStyle(.secondary)
                }
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
                    .disabled(totalSeconds <= 0)
                }
            }
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
                    ForEach(CountdownReminderPreset.allCases) { preset in
                        Button {
                            togglePreset(preset)
                        } label: {
                            HStack {
                                Text(preset.title)
                                Spacer()
                                if reminderDrafts.contains(where: { $0.secondsBeforeEvent == preset.secondsBeforeEvent }) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Custom...") {
                        showCustomReminderSheet = true
                    }

                    if !reminderDrafts.isEmpty {
                        ForEach(reminderDrafts) { reminder in
                            HStack {
                                Text(reminder.title)
                                Spacer()
                                Button(role: .destructive) {
                                    removeReminder(reminder)
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                }
                                .buttonStyle(.borderless)
                            }
                        }
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
            CustomReminderSheet { draft in
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

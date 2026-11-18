//
//  CountdownListView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 17/5/25.
//

import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject private var countdownStore: CountdownStore
    @EnvironmentObject private var sheetStore: SheetStore

    let countdowns: [CountdownItem]
    let onClose: (() -> Void)?

    @State private var searchText = ""
    @State private var countdownToEdit: CountdownItem?
    @State private var countdownToDelete: CountdownItem?
    @State private var isDeleteConfirmationPresented = false

    private var filteredCountdowns: [CountdownItem] {
        guard !searchText.isEmpty else {
            return countdowns
        }

        return countdowns.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var countdownsByMonth: [Date: [CountdownItem]] {
        let calendar = Calendar.current

        return Dictionary(grouping: filteredCountdowns) { item in
            let components = calendar.dateComponents([.year, .month], from: item.date)
            return calendar.date(from: components) ?? item.date
        }
    }

    private var sortedMonths: [Date] {
        countdownsByMonth.keys.sorted()
    }

    init(
        countdowns: [CountdownItem],
        onClose: (() -> Void)? = nil
    ) {
        self.countdowns = countdowns
        self.onClose = onClose
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedMonths, id: \.self) { month in
                    CountdownMonthSection(
                        month: month,
                        items: countdownsByMonth[month] ?? [],
                        onSelectCountdown: selectCountdown,
                        onEditCountdown: editCountdown,
                        onDeleteCountdown: presentDeleteConfirmation
                    )
                }
            }
            .listStyle(.plain)
            .listRowSeparator(.hidden)
            .searchable(text: $searchText, prompt: "Search countdowns")
        }
        .sheet(item: $countdownToEdit) { countdown in
            AddCountdownView(countdownToEdit: countdown)
        }
        .alert(
            "Delete Countdown?",
            isPresented: $isDeleteConfirmationPresented,
            presenting: countdownToDelete
        ) { countdown in
            Button("Delete", role: .destructive) {
                deleteCountdown(countdown)
            }
            Button("Cancel", role: .cancel) {
                countdownToDelete = nil
            }
        } message: { countdown in
            Text("“\(countdown.name)” will be removed from your countdowns.")
        }
    }

    private func selectCountdown(_ countdown: CountdownItem) {
        sheetStore.isSelectedCountdown = countdown
    }

    private func editCountdown(_ countdown: CountdownItem) {
        countdownToEdit = countdown
    }

    private func presentDeleteConfirmation(_ countdown: CountdownItem) {
        countdownToDelete = countdown
        isDeleteConfirmationPresented = true
    }

    private func deleteCountdown(_ countdown: CountdownItem) {
        countdownStore.deleteCountdown(countdown)
        countdownToDelete = nil
        onClose?()
    }
}

private struct CountdownMonthSection: View {
    let month: Date
    let items: [CountdownItem]
    let onSelectCountdown: (CountdownItem) -> Void
    let onEditCountdown: (CountdownItem) -> Void
    let onDeleteCountdown: (CountdownItem) -> Void

    var body: some View {
        Section(header: Text(month, format: .dateTime.month(.wide).year())) {
            if items.isEmpty {
                EmptyCountdownMonthRow(month: month)
            } else {
                ForEach(items, id: \.id) { countdown in
                    CountdownRow(
                        item: countdown,
                        onTap: { onSelectCountdown(countdown) }
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 15, leading: 15, bottom: 15, trailing: 15))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            onDeleteCountdown(countdown)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)

                        Button {
                            onEditCountdown(countdown)
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.orange)
                    }
                }
            }
        }
    }
}

private struct EmptyCountdownMonthRow: View {
    let month: Date

    var body: some View {
        ZStack {
            NavigationLink(destination: AddCountdownView(countdownDate: month)) {
                EmptyView()
            }

            HStack {
                Spacer()
                Label("Add countdown", systemImage: "plus")
                    .frame(maxWidth: .infinity, maxHeight: 60)
                    .font(.caption)
                    .padding(28)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                            .foregroundColor(.primary)
                    )
                Spacer()
            }
            .opacity(0.4)
            .padding(.vertical, 4)
        }
        .foregroundStyle(.primary)
        .listRowBackground(Color.clear)
        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}

#Preview {
    CountdownListView(
        countdowns: [
            CountdownItem.SamplePastTimer,
            CountdownItem.Graduation,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
            CountdownItem.SampleFutureTimer,
        ],
    )
    .environmentObject(SheetStore())
}

//
//  CountdownListView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 17/5/25.
//

import SwiftUI

struct CountdownListView: View {
    @EnvironmentObject private var modalStore: ModalStore

    let countdowns: [CountdownItem]
    let onClose: (() -> Void)?

    @State private var searchText = ""

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

    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        return formatter
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
                        monthYearFormatter: monthYearFormatter,
                        onSelectCountdown: selectCountdown
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search countdowns")
        }
    }

    private func selectCountdown(_ countdown: CountdownItem) {
        modalStore.isSelectedCountdown = countdown
    }
}

private struct CountdownMonthSection: View {
    let month: Date
    let items: [CountdownItem]
    let monthYearFormatter: DateFormatter
    let onSelectCountdown: (CountdownItem) -> Void

    var body: some View {
        Section(header: Text(month, formatter: monthYearFormatter)) {
            if items.isEmpty {
                EmptyCountdownMonthRow(month: month)
            } else {
                ForEach(items, id: \.id) { countdown in
                    CountdownListItemView(
                        item: countdown,
                        onTap: { onSelectCountdown(countdown) }
                    )
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
    .environmentObject(ModalStore())
}

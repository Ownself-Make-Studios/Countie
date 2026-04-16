//
//  ContentView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/10/24.
//

import SwiftData
import SwiftUI
import WidgetKit

struct ContentView: View {
    @EnvironmentObject var store: CountdownStore
    @EnvironmentObject var modalStore: ModalStore

    @Environment(\.modelContext) private var modelContext
    @State private var countdowns: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var showCalendarModal = false
    @State private var searchText: String = ""
    //    @State private var selectedTab: Tabs = .comingup

    private func onCloseModal() {
        store.fetchCountdowns()
    }

    var body: some View {
        NavigationStack {
            VStack {

                if store.upcomingCountdowns.isEmpty {
                    Spacer(minLength: 0)
                    ContentUnavailableView(
                        "No Countdowns Yet :(",
                        systemImage: "calendar",
                        description: Text(
                            "Add a countdown by tapping the plus button!"
                        )
                    )
                    Spacer(minLength: 0)
                } else {
                    CountdownListView(
                        countdowns: store.upcomingCountdowns,
                        onClose: onCloseModal,
                    ).refreshable {
                        store.fetchCountdowns()
                    }
                }

                //                TabView(selection: $selectedTab) {
                //
                //                    Tab(
                //                        "Coming Up",
                //                        systemImage: "calendar.badge.clock",
                //                        value: .comingup
                //                    ) {}
                //
                //                    Tab(
                //                        "Past Events",
                //                        systemImage:
                //                            "clock.arrow.trianglehead.counterclockwise.rotate.90",
                //                        value: .pastevents
                //                    ) {}
                //
                //                    //                        Tab(value: .search, role: .search) {
                //                    //                            ContentUnavailableView(
                //                    //                                "Work in progress",
                //                    //                                systemImage: "magnifyingglass",
                //                    //                                description: Text(
                //                    //                                    "This page is a work in progess. Please check back later!"
                //                    //                                )
                //                    //                            )
                //                    //
                //                    //                        }
                //                }

            }
            .toolbar {
                ToolbarItem {
                    NavigationLink(
                        destination:
                            NavigationStack {
                                PastCountdownsView(
                                    onClose: onCloseModal
                                )
                            }.navigationTitle("Past Countdowns")
                    ) {
                        Label(
                            "Past Countdowns",
                            systemImage:
                                "clock.arrow.trianglehead.counterclockwise.rotate.90"
                        )
                        .labelStyle(.titleAndIcon)
                    }
                }

                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                            .labelStyle(.titleAndIcon)
                    }
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button(action: {
                            showCalendarModal = true
                        }) {
                            Label(
                                "Add from calendar",
                                systemImage: "calendar.badge.plus"
                            )
                        }

                        Button(action: {
                            showAddModal = true
                        }) {
                            Label("Custom", systemImage: "plus")
                                .labelStyle(.titleAndIcon)
                        }

                    } label: {
                        Label("Add Countdown", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                    }
                }

            }
            .navigationTitle("Countie")
        }
        .sheet(isPresented: $showAddModal) {
            NavigationView {
                AddCountdownView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddModal = false
                            }
                        }

                    }
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showCalendarModal) {
            NavigationView {
                CalendarEventsView(
                    onSelectEvent: { _ in
                        showAddModal = false
                        showCalendarModal = false
                        store.fetchCountdowns()
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showCalendarModal = false
                        }
                    }

                }
            }
            .navigationTitle("Add from Calendar")
        }
        .sheet(item: $modalStore.isSelectedCountdown) { countdown in
            NavigationView {
                CountdownDetailView(
                    countdown: countdown,
                ) {
                    store.fetchCountdowns()
                }

            }
        }
        .onChange(of: showAddModal) { oldValue, newValue in
            if oldValue != newValue && newValue == false {
                // AddCountdownView was dismissed
                store.fetchCountdowns()
            }
        }
    }

}

#Preview {
    ContentView()
        .modelContainer(NomaModelContainer.sharedModelContainer)
    //        .modelContainer(for: CountdownItem.self, inMemory: true)
}

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
    @EnvironmentObject var countdownStore: CountdownStore
    @EnvironmentObject var sheetStore: SheetStore

    @Environment(\.modelContext) private var modelContext
    @State private var countdowns: [CountdownItem] = []
    @State private var showAddModal = false
    @State private var showCalendarModal = false
    @State private var searchText: String = ""
    //    @State private var selectedTab: Tabs = .comingup

    private func onCloseModal() {
        countdownStore.fetchCountdowns()
    }

    var body: some View {
        NavigationStack {
            VStack {

                if countdownStore.upcomingCountdowns.isEmpty {
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
                        countdowns: countdownStore.upcomingCountdowns,
                        onClose: onCloseModal,
                    ).refreshable {
                        countdownStore.fetchCountdowns()
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
            
//            .navigationTitle("Countie")
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
                    
                    Button(action: {
                            showAddModal = true
                        }) {
                            Label("Add Countdown", systemImage: "plus")
                            .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(.borderedProminent)

//                    Menu {
//                        Button(action: {
//                            showCalendarModal = true
//                        }) {
//                            Label(
//                                "Add from calendar",
//                                systemImage: "calendar.badge.plus"
//                            )
//                            .labelStyle(.titleAndIcon)
//                        }
//                        .disabled(true)
//
//                        Button(action: {
//                            showAddModal = true
//                        }) {
//                            Label("Add Manually", systemImage: "square.and.pencil")
//                                .labelStyle(.titleAndIcon)
//                        }
//
//                    } label: {
//                        Label("Add Countdown", systemImage: "plus")
//                            .labelStyle(.titleAndIcon)
//                    }
//                    .buttonStyle(.borderedProminent)
                }

            }
        }
//        .overlay(alignment: .bottom) {
//            if #available(iOS 26.0, *) {
//                GlassEffectContainer(spacing: 0){
//                    HStack(spacing: 5){
//                        
//                        Button {
//                            
//                        } label : {
//                            Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
//                                .font(.title3)
//                                .frame(width: 30, height: 35)
//                        }
//                        .buttonStyle(.glass)
//                        
//                        ScrollView(.horizontal, showsIndicators: false){
//                            LazyHStack(spacing: 0){
//                                 VStack{
//                                    Text("January")
//                                         .bold()
//                                     Text("2026")
//                                         .font(.caption2)
//                                         
//                                }
//                                    .containerRelativeFrame(.horizontal)
//                                    .frame(maxHeight: .infinity)
//                                    .clipShape(.capsule)
//                                    .glassEffect(.regular.tint(.white.opacity(0.1)))
//                            Text("Feb 2026")
//                                    .containerRelativeFrame(.horizontal)
//                                    .frame(maxHeight: .infinity)
//                                .clipShape(.capsule)
//                                    .glassEffect(.regular.tint(.white.opacity(0.1)))
//                                VStack{
//                                    Text("2026")
//                                    Text("Mar")
//                                }
//                                    .containerRelativeFrame(.horizontal)
//                                    .frame(maxHeight: .infinity)
//                                .clipShape(.capsule)
//                                    .glassEffect(.regular.tint(.white.opacity(0.1)))
//                            }
//                        }
//                        .frame(height: 45)
//                        .scrollTargetBehavior(.paging)
//                        .clipShape(.capsule)
//                        .padding(5)
//                        .glassEffect(.clear.interactive(false), in: .capsule)
//
//                        Button {
//                            
//                        } label : {
//                            Label("Add", systemImage: "plus")
//                                .padding(.horizontal, 10)
//                                .frame(height: 35)
////                                Image(systemName: "plus")
////                                    .font(.title3)
////                                    .frame(width: 30, height: 40)
//                        }
//                        .buttonStyle(.glassProminent)
//                    }
//                    
//                }
//                .padding()
//            } else {
//                // Fallback on earlier versions
//            }
//            
//        }
        .sheet(isPresented: $showAddModal) {
            NavigationStack {
                AddCountdownView()
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showAddModal = false
                            }
                        }

                    }
                    .presentationSizing(CustomPresentationSizing())
            }
            .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showCalendarModal) {
            NavigationStack {
                CalendarEventsView(
                    onSelectEvent: { _ in
                        showAddModal = false
                        showCalendarModal = false
                        countdownStore.fetchCountdowns()
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
        }
        .sheet(item: $sheetStore.isSelectedCountdown) { countdown in
            NavigationView {
                CountdownDetailView(
                    countdown: countdown,
                ) {
                    countdownStore.fetchCountdowns()
                }
                .presentationSizing(CustomPresentationSizing())

            }
        }
        .onChange(of: showAddModal) { oldValue, newValue in
            if oldValue != newValue && newValue == false {
                // AddCountdownView was dismissed
                countdownStore.fetchCountdowns()
            }
        }
    }

}

// https://stackoverflow.com/a/79020867
struct CustomPresentationSizing: PresentationSizing {
    func proposedSize(for root: PresentationSizingRoot, context: PresentationSizingContext) -> ProposedViewSize {
        .init(width: 500, height: 800)
    }
}

#Preview {
    let container = CountieModelContainer.sharedModelContainer
    let store = CountdownStore(context: container.mainContext)
    ContentView()
        .modelContainer(container)
        .environmentObject(store)
        .environmentObject(SheetStore())
}

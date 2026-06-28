//
//  PastCountdownsView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/8/25.
//

import SwiftUI

struct PastCountdownsView: View {
    @EnvironmentObject private var store: CountdownStore
    var onClose: (() -> Void)? = nil
    
    var body: some View {
        if store.passedCountdowns.isEmpty {
            Spacer(minLength: 0)
            ContentUnavailableView(
                "No Past Countdowns",
                systemImage: "calendar",
                description: Text(
                    "Your past countdowns will appear here once they're done."
                )
            )
            Spacer(minLength: 0)
        } else {
            CountdownListView(
                countdowns: store.passedCountdowns,
                onClose: onClose
            )
            .refreshable {
                store.fetchCountdowns()
            }
        }

    }
}

#Preview {
    PastCountdownsView()
}

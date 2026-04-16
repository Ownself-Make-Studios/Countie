//
//  Countdown.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Countdown: View {
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            CountdownListItemView(item: CountdownItem.Graduation)
                .padding()
                .background(
                    .clear,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )

            VStack(spacing: 12) {
                Text("Create Meaningful Countdowns")
                    .font(.title)
                    .bold()
                Text("Count down to anything that matters to you, whether it is graduation, a trip, a birthday, or a quiet personal goal.")
                    .foregroundStyle(.secondary)
                Text("When you connect your calendar and notifications, Countie can turn scheduled events into countdowns and remind you before they arrive.")
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Countdown()
}

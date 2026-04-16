//
//  CountdownListItemView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 29/10/24.
//

internal import Combine
import SwiftUI

struct CountdownListItemView: View {

    @AppStorage("showProgress") private var showProgress: Bool = true
    @State var item: CountdownItem
    var onTap: (() -> Void)? = nil

    @State private var currentTime = Date()
    @State private var timerCancellable: Cancellable?

    var countdownHasEnded: Bool {
        item.date < currentTime
    }

    var hasReminder: Bool {
        !item.reminders.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            HStack(spacing: 10) {

                CircularEmojiView(
                    iconName: item.resolvedIconName,
                    tint: item.eventTintColor,
                    progress: Float(item.progress),
                    showProgress: showProgress
                )

                VStack(alignment: .leading) {

                    Text("\(item.name)")
                        //                        .font(.caption)
                        .font(.system(size: 15))
                        .bold()

                    Text(item.formattedDateString)
                        .font(.caption)
                        .opacity(0.5)
                }

                Spacer()

                HStack(spacing: 8) {

                    item.calendarEventIdentifier != nil
                        ? Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 12, height: 16)
                            .opacity(0.5)
                        : nil

                    hasReminder
                        ? Image(systemName: "bell")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 12, height: 16)
                            .opacity(0.5)
                        : nil

                    Text(
                             item.getTimeRemainingFn(since: currentTime)
                    )
                    .font(.caption2)
                    .opacity(0.5)
                }

            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
        }
        .padding(.vertical, 6)
        .opacity(countdownHasEnded ? 0.5 : 1.0)
        .onAppear {
            if !countdownHasEnded {
                // Start the timer when the view appears
                timerCancellable = Timer.publish(
                    every: 1,
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .sink { input in
                    currentTime = input
                }
            } else {
                // Start the timer when the view appears
                // to update the view even if the countdown has ended
                timerCancellable = Timer.publish(
                    every: 1 * 60 * 60,
                    on: .main,
                    in: .common
                )
                .autoconnect()
                .sink { input in
                    currentTime = input
                }
            }
        }
        .onDisappear {
            //             Cancel the timer when the view disappears to prevent memory leaks
            timerCancellable?.cancel()
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CountdownListItemView(
        item: .Graduation
    )
    
}

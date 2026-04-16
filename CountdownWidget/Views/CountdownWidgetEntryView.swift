//
//  CountdownWidgetEntryView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 25/10/24.
//

import SwiftData
import SwiftUI
import WidgetKit

struct CountdownWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var deeplinkURL: URL? {
        if let countdownItem = entry.countdownItem {
            return URL(string: "countie://countdown/\(countdownItem.id.uuidString)")
        }
        return nil
    }

    var body: some View {
        Group {
            if let countdownItem = entry.countdownItem {
                switch family {
                case .systemSmall:
                    CountdownWidgetSmallView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                case .systemMedium:
                    CountdownWidgetMediumView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                case .systemLarge:
                    CountdownWidgetLargeView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                case .accessoryRectangular:
                    CountdownWidgetAccessoryRectangularView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                case .accessoryInline:
                    CountdownWidgetAccessoryInlineView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                case .accessoryCircular:
                    CountdownWidgetAccessoryCircularView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                default:
                    CountdownWidgetSmallView(
                        countdownItem: countdownItem,
                        showProgress: entry.showProgress
                    )
                }
            } else {
                Text("No countdowns to display")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .widgetURL(deeplinkURL)
    }
}

struct CountdownWidgetSmallView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                CircularEmojiView(
                    emoji: countdownItem.emoji ?? "",
                    progress: showProgress ? Float(countdownItem.progress) : 0,
                    showProgress: showProgress,
                    width: 34
                )
                Spacer()
            }
            .padding(.bottom, 6)

            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
            Text(countdownItem.getTimeRemainingFn())
                .font(.caption)
                .opacity(0.6)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)

            //            if showProgress {
            //                Spacer(minLength: 0)
            //                HStack(spacing: 6) {
            //                    LinearProgressView(value: countdownItem.progress, shape: Capsule())
            //                        .tint(
            //                            LinearGradient(
            //                                colors: [.purple, .blue],
            //                                startPoint: .leading,
            //                                endPoint: .trailing)
            //                        )
            //                        .frame(height: 9)
            //
            //                    Text("\(countdownItem.progressString)%")
            //                        .font(.caption)
            //                        .opacity(0.4)
            //
            //                }
            //            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        //        .background(.red)
    }
}

struct CountdownWidgetMediumView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.title)
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
            Text(countdownItem.getTimeRemainingFn())
                .font(.caption)
                .opacity(0.6)
                .minimumScaleFactor(0.5)

            if showProgress {

                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    LinearProgressView(
                        value: countdownItem.progress,
                        shape: Capsule()
                    )
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 9)

                    Text("\(countdownItem.progressString)%")
                        .font(.caption)
                        .opacity(0.4)

                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetLargeView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let emoji = countdownItem.emoji, !emoji.isEmpty {
                Text(emoji)
                    .font(.title)
                    .frame(height: 44)
            }
            Text(countdownItem.name)
                .font(.headline)
                .bold()
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .minimumScaleFactor(0.5)
            Text(countdownItem.getTimeRemainingFn())
                .font(.caption)
                .opacity(0.6)
                .minimumScaleFactor(0.5)

            if showProgress {

                Spacer(minLength: 0)

                HStack(spacing: 6) {
                    LinearProgressView(
                        value: countdownItem.progress,
                        shape: Capsule()
                    )
                    .tint(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 9)

                    Text("\(countdownItem.progressString)%")
                        .font(.caption)
                        .opacity(0.4)

                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetAccessoryRectangularView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    // Show time remaining with progress percentage if showProgress is true
    var timeRemainingWidgetString: String {
        return countdownItem.getTimeRemainingFn()
//        if showProgress {
//            return countdownItem.timeRemainingWidgetString
//                + " (\(countdownItem.progressString)%)"
//        } else {
//            return countdownItem.timeRemainingWidgetString
//        }
    }

    var body: some View {
        HStack {
            HStack {
                CircularEmojiView(
                    emoji: countdownItem.emoji ?? "",
                    progress: showProgress ? Float(countdownItem.progress) : 0,
                    showProgress: showProgress,
                    width: 28,
                    emojiSize: 14
                    
                )
            }
            .padding(.trailing, 4)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(countdownItem.name)")
                    .font(.body)
                    .bold()
                    .minimumScaleFactor(0.5)

                Text(timeRemainingWidgetString)
                    .font(.caption)
                    .opacity(0.6)
                    .minimumScaleFactor(0.5)

            }
            
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
//            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CountdownWidgetAccessoryInlineView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    // Show time remaining with progress percentage if showProgress is true
    var timeRemainingWidgetString: String {
        if showProgress {
            return countdownItem.getTimeRemainingFn()
                + " (\(countdownItem.progressString)%)"
        } else {
            return countdownItem.getTimeRemainingFn()
        }
    }

    var body: some View {
        HStack {
            Text("\(countdownItem.emoji ?? "") \(timeRemainingWidgetString)")
                .font(.body)
        }
    }
}

struct CountdownWidgetAccessoryCircularView: View {
    let countdownItem: CountdownItem
    let showProgress: Bool

    var timeRemainingWidgetString: String {
        if showProgress {
            "\(Int(countdownItem.progress * 100))%"
        } else {
            countdownItem.biggestUnitShortString
        }

    }

    var body: some View {
        ZStack {
            Gauge(value: countdownItem.progress) {
                Text(timeRemainingWidgetString)
            } currentValueLabel: {
                Text(countdownItem.emoji ?? "")
            }
            .gaugeStyle(.accessoryCircular)
        }
    }
}

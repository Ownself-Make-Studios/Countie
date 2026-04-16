//
//  CircularEmojiView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 23/7/25.
//

import SwiftUI

struct CircularEventIconView: View {
    var iconName: String = CountdownEventIcon.default
    var tint: Color = CountdownEventColor.blue.color
    var progress: Float = 0.8  // Default progress value
    var showProgress: Bool = true

    var width: Int = 34
    var brightness: Double = 0.3
    var lineWidth: CGFloat = 3.0
    var gap: CGFloat = 10.0
    var iconSize: CGFloat = 18.0

    var body: some View {
        Circle()
            .frame(width: CGFloat(width))
            .foregroundStyle(tint.opacity(0.16))
            .overlay {
                Image(systemName: iconName)
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(tint)

                if showProgress {
                    CircularProgressBar(
                        progress: progress,
                        color: tint,
                        lineWidth: lineWidth
                    )
                    .frame(
                        width: CGFloat(CGFloat(width) + gap),
                        height: CGFloat(CGFloat(width) + gap)
                    )
                }
            }
            .padding(.horizontal, showProgress ? 4 : 0)

    }
}

typealias CircularEmojiView = CircularEventIconView

#Preview(traits: .sizeThatFitsLayout) {
    CircularEventIconView(showProgress: true)
}

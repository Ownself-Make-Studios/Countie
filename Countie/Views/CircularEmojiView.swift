//
//  CircularEmojiView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 23/7/25.
//

import SwiftUI

struct CircularEmojiView: View {
    var emoji: String = "🎉"  // Default emoji
    var progress: Float = 0.8  // Default progress value
    var showProgress: Bool = true

    var width: Int = 34
    var brightness: Double = 0.3
    var lineWidth: CGFloat = 3.0
    var gap: CGFloat = 10.0
    var emojiSize: CGFloat = 18.0

    var body: some View {
        Circle()
            .frame(width: CGFloat(width))
            .foregroundStyle(
                Color(vibrantDominantColorOf: emoji) ?? .gray.opacity(0.3)
            )
            .overlay {
                Text("\(emoji)")
                    .font(.system(size: emojiSize))

                if showProgress {
                    CircularProgressBar(
                        progress: progress,
                        color: Color(vibrantDominantColorOf: emoji)
                            ?? .gray.opacity(0.8),
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

#Preview(traits: .sizeThatFitsLayout) {
    CircularEmojiView(showProgress: true)
}

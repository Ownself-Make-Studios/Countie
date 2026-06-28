//
//  CountdownEventColor.swift
//  Countie
//
//  Created by Nabil Ridhwan on 28/6/26.
//


import Foundation
import SwiftUI

private extension Color {
    static func palette(_ red: Int, _ green: Int, _ blue: Int) -> Color {
        Color(
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0
        )
    }
}

enum CountdownEventColor: String, CaseIterable, Codable, Identifiable {
    case berry
    case brick
    case orange
    case gold
    case peach
    case apricot
    case cream
    case sand
    case salmon
    case blush
    case coral
    case pink
    case mauve
    case lavender
    case periwinkle
    case violet
    case purple
    case slate
    case blue
    case sea
    case cyan
    case mint
    case sage
    case mist
    case stone

    var id: String { rawValue }

    var title: String {
        switch self {
        case .berry: "Berry"
        case .brick: "Brick"
        case .orange: "Orange"
        case .gold: "Gold"
        case .peach: "Peach"
        case .apricot: "Apricot"
        case .cream: "Cream"
        case .sand: "Sand"
        case .salmon: "Salmon"
        case .blush: "Blush"
        case .coral: "Coral"
        case .pink: "Pink"
        case .mauve: "Mauve"
        case .lavender: "Lavender"
        case .periwinkle: "Periwinkle"
        case .violet: "Violet"
        case .purple: "Purple"
        case .slate: "Slate"
        case .blue: "Blue"
        case .sea: "Sea"
        case .cyan: "Cyan"
        case .mint: "Mint"
        case .sage: "Sage"
        case .mist: "Mist"
        case .stone: "Stone"
        }
    }

    var color: Color {
        switch self {
        case .berry:
            return .palette(124, 68, 79)
        case .brick:
            return .palette(159, 82, 85)
        case .orange:
            return .palette(255, 145, 71)
        case .gold:
            return .palette(237, 184, 105)
        case .peach:
            return .palette(255, 180, 162)
        case .apricot:
            return .palette(255, 205, 178)
        case .cream:
            return .palette(255, 242, 239)
        case .sand:
            return .palette(242, 234, 224)
        case .salmon:
            return .palette(250, 104, 104)
        case .blush:
            return .palette(247, 165, 165)
        case .coral:
            return .palette(255, 115, 148)
        case .pink:
            return .palette(255, 92, 163)
        case .mauve:
            return .palette(221, 174, 211)
        case .lavender:
            return .palette(189, 166, 206)
        case .periwinkle:
            return .palette(155, 142, 199)
        case .violet:
            return .palette(127, 85, 177)
        case .purple:
            return .palette(196, 87, 245)
        case .slate:
            return .palette(93, 104, 138)
        case .blue:
            return .palette(94, 133, 255)
        case .sea:
            return .palette(90, 156, 181)
        case .cyan:
            return .palette(64, 186, 242)
        case .mint:
            return .palette(79, 209, 189)
        case .sage:
            return .palette(111, 143, 114)
        case .mist:
            return .palette(180, 211, 217)
        case .stone:
            return .palette(191, 198, 196)
        }
    }
}

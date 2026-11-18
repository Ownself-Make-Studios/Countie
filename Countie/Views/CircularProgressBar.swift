//
//  ProgressBar.swift
//  Countie
//
//  Created by Nabil Ridhwan on 23/7/25.
//  From: https://youtu.be/ikoS43QtLYE?si=w4GUBABBG2l10Qnz

import SwiftUI

struct CircularProgressBar: View {
    var progress: Float
    var color: Color = Color.green
    var lineWidth = 3.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(color)
                .opacity(0.3)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor (color).rotationEffect (Angle(degrees: 270))
        }
        
    }
}

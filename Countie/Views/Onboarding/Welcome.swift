//
//  Welcome.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 8){
            
            Image(
                systemName: "timer.circle"
            )
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            
            VStack {
                Text("Welcome to Countie")
                    .font(.title)
                    .bold()
                Text("Track Life’s Milestones, One Countdown at a Time")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Welcome()
}

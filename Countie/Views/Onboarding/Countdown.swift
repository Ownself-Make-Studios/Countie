//
//  Countdown.swift
//  Countie
//
//  Created by Nabil Ridhwan on 22/6/25.
//

import SwiftUI

struct Countdown: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 8){
            
//            Image(
//                systemName: "timer.circle"
//            )
//            .resizable()
//            .aspectRatio(contentMode: .fit)
//            .frame(width: 100, height: 100)
            
            CountdownListItemView(item: CountdownItem.Graduation)
                .padding()
                .background(
                    .clear,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                        
                )
            
            VStack {
                Text("Create Meaningful Countdowns")
                    .font(.title)
                    .bold()
                Text("From big days like graduation 🎓 to simple plans like your next vacation 🏖️ — it’s just a few taps away.")
            }
        }
        .multilineTextAlignment(.center)
        .padding(28)
    }
}

#Preview {
    Countdown()
}

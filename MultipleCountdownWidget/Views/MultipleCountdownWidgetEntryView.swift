//
//  MultipleCountdownWidgetEntryView.swift
//  Countie
//
//  Created by Nabil Ridhwan on 25/6/25.
//


import WidgetKit
import SwiftUI
import SwiftData

struct MultipleCountdownWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
//            Rectangle()
//                .fill(
//                    LinearGradient(colors: [Color.pink, Color.red], startPoint: .top, endPoint: .bottom)
//                )
//                .overlay{
//                        HStack(spacing: 4){
//                            Image(systemName: "timer")
//                            Text("Countdowns")
//                        }
//                        .bold()
//                        .font(.subheadline)
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .leading)
//                        .padding(.horizontal, 18)
//                }
//                .frame(height: 44)
            
            
            
            
            ForEach(Array(entry.countdowns.enumerated()), id: \ .element.id) { index, countdownItem in
                HStack {
                    Image(systemName: countdownItem.resolvedIconName)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(countdownItem.eventTintColor)

                    Text(countdownItem.name)
                        .lineLimit(1)
                        .font(.footnote)
                    
                    Spacer()
                    
//                    LinearProgressView(value: countdownItem.progress, shape: Capsule())
//                        .tint(
//                            LinearGradient(
//                                colors: [.purple, .blue],
//                                startPoint: .leading,
//                                endPoint: .trailing)
//                        )
//                        .frame(width: 40, height: 10)
                    
                    
                    Text(
                        "\(countdownItem.getTimeRemainingFn())"
                    )
                        .opacity(0.5)
                        .font(.caption2)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
                .background(index % 2 == 0 ? .secondary.opacity(0.1) : Color.clear)
            }
            
            Spacer()
        }
        //        .background(
        //            Color.black.opacity(0.2)
        //                .ignoresSafeArea(edges: .all)
        //        )
        
    }
}
